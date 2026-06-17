local docs = require("kathi.stacks.godot.docs")

local M = {}

local GODOT_FTS = { gdscript = true, gdshader = true, gdresource = true, csharp = true }
local SCRIPT_FTS = { gdscript = true, csharp = true }

local function is_godot_project(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return false
  end
  return vim.fs.root(name, { "project.godot" }) ~= nil
end

local function should_map(bufnr)
  return GODOT_FTS[vim.bo[bufnr].filetype] and is_godot_project(bufnr)
end

local function map_opts(bufnr, desc)
  return { buffer = bufnr, noremap = true, silent = true, desc = desc }
end

function M.setup_dap()
  local dap = require("dap")
  local dapui = require("dapui")

  if not M._dapui_ready then
    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },
    })

    dap.listeners.after.event_initialized["kathi_godot_dapui"] = function()
      dapui.open({ reset = true })
    end
    dap.listeners.before.event_terminated["kathi_godot_dapui"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["kathi_godot_dapui"] = function()
      dapui.close()
    end

    M._dapui_ready = true
  end

  local ok, mason_dap = pcall(require, "mason-nvim-dap")
  if ok then
    mason_dap.setup({
      ensure_installed = { "netcoredbg" },
      automatic_installation = true,
    })
  end
end

function M.setup_buffer_keymaps(bufnr)
  if not should_map(bufnr) then
    return
  end
  if vim.b[bufnr].kathi_godot_keymaps then
    return
  end
  vim.b[bufnr].kathi_godot_keymaps = true

  local map = vim.keymap.set
  local ft = vim.bo[bufnr].filetype

  map("n", "gK", function()
    docs.open()
  end, map_opts(bufnr, "Godot class docs"))
  map("n", "<leader>gl", "<cmd>GodotReconnectLSP<cr>", map_opts(bufnr, "Godot reconnect LSP"))
  map("n", "<leader>gp", "<cmd>GodotRunProject<cr>", map_opts(bufnr, "Godot run project"))
  map("n", "<leader>gS", "<cmd>GodotRunScenePicker<cr>", map_opts(bufnr, "Godot run scene picker"))
  map("n", "<leader>gt", "<cmd>GodotSceneTree<cr>", map_opts(bufnr, "Godot scene tree"))
  map("n", "<leader>gR", "<cmd>GodotSceneTreeRefresh<cr>", map_opts(bufnr, "Godot refresh scene tree"))

  if ft == "gdscript" then
    map("n", "<leader>gh", "<cmd>GodotToggleInlineHints<cr>", map_opts(bufnr, "Godot toggle inline hints"))
  end

  if SCRIPT_FTS[ft] then
    map("n", "<leader>gs", "<cmd>GodotRunCurrentScene<cr>", map_opts(bufnr, "Godot run current scene"))

    local dap = require("dap")
    local dapui = require("dapui")

    map("n", "<leader>gD", dap.continue, map_opts(bufnr, "Godot debug session"))
    map("n", "<leader>db", dap.toggle_breakpoint, map_opts(bufnr, "Toggle breakpoint"))
    map("n", "<leader>dB", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, map_opts(bufnr, "Conditional breakpoint"))
    map("n", "<leader>dc", dap.continue, map_opts(bufnr, "Debug continue"))
    map("n", "<leader>do", dap.step_over, map_opts(bufnr, "Step over"))
    map("n", "<leader>di", dap.step_into, map_opts(bufnr, "Step into"))
    map("n", "<leader>dO", dap.step_out, map_opts(bufnr, "Step out"))
    map("n", "<leader>du", dapui.toggle, map_opts(bufnr, "Toggle DAP UI"))
    map("n", "<leader>de", dapui.eval, map_opts(bufnr, "Eval expression"))
    map("n", "<leader>dx", dap.terminate, map_opts(bufnr, "Terminate debug"))
  end
end

function M.setup()
  docs.setup()
  M.setup_dap()

  local group = vim.api.nvim_create_augroup("KathiGodot", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
    group = group,
    callback = function(args)
      M.setup_buffer_keymaps(args.buf)
    end,
  })
end

return M
