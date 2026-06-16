local notify = require("kathi.utils.notify")
local paths = require("kathi.utils.paths")

local M = {}

local VENV_NAMES = { ".venv", "venv", "env", ".env" }
local setup_done = false

local function find_project_root(start_dir)
  local dir = start_dir or paths.cwd()
  while dir and dir ~= "/" do
    if vim.fn.filereadable(dir .. "/manage.py") == 1
      or vim.fn.filereadable(dir .. "/pyproject.toml") == 1
      or vim.fn.isdirectory(dir .. "/.git") == 1 then
      return dir
    end
    dir = paths.dirname(dir)
  end
  return start_dir or paths.cwd()
end

local function persist_file(root)
  return root .. "/.kathi/venv"
end

local function normalize_venv_path(path)
  if not path or path == "" then
    return nil
  end
  local normalized = vim.fn.fnamemodify(path, ":p")
  if normalized:match("/bin/python3?$") then
    normalized = paths.dirname(paths.dirname(normalized))
  end
  if vim.fn.isdirectory(normalized) == 1 then
    return normalized
  end
  return nil
end

function M.project_root()
  local buf = vim.api.nvim_buf_get_name(0)
  local start = (#buf > 0 and vim.fn.fnamemodify(buf, ":p:h")) or paths.cwd()
  return find_project_root(start)
end

function M.discover(start_dir)
  local found = {}
  local seen = {}
  local dir = start_dir or M.project_root()

  while dir and dir ~= "/" do
    for _, name in ipairs(VENV_NAMES) do
      local venv_path = dir .. "/" .. name
      local python = venv_path .. "/bin/python"
      if vim.fn.isdirectory(venv_path) == 1 and vim.fn.executable(python) == 1 and not seen[venv_path] then
        seen[venv_path] = true
        table.insert(found, venv_path)
      end
    end
    dir = paths.dirname(dir)
  end

  return found
end

function M.read_persisted(root)
  root = root or M.project_root()
  local file = persist_file(root)
  if vim.fn.filereadable(file) ~= 1 then
    return nil
  end
  local lines = vim.fn.readfile(file)
  return normalize_venv_path(lines[1])
end

function M.get()
  if M._override then
    return M._override
  end

  local persisted = M.read_persisted()
  if persisted then
    return persisted
  end

  local venv_env = vim.env.VIRTUAL_ENV
  if venv_env and venv_env ~= "" and vim.fn.isdirectory(venv_env) == 1 then
    return venv_env
  end

  local discovered = M.discover()
  return discovered[1]
end

function M.set(path)
  local venv_dir = normalize_venv_path(path)
  if not venv_dir then
    notify.error("Invalid venv path: " .. tostring(path), "kathi.python")
    return false
  end

  local python = venv_dir .. "/bin/python"
  if vim.fn.executable(python) ~= 1 then
    notify.error("No python executable in venv: " .. python, "kathi.python")
    return false
  end

  local root = M.project_root()
  vim.fn.mkdir(root .. "/.kathi", "p")
  vim.fn.writefile({ venv_dir }, persist_file(root))
  M._override = venv_dir
  return true
end

function M.python_executable()
  local venv = M.get()
  if venv then
    local bin = venv .. "/bin/python"
    if vim.fn.executable(bin) == 1 then
      return bin
    end
  end
  if vim.fn.executable("python3") == 1 then
    return "python3"
  end
  return "python"
end

function M.pyright_settings()
  local venv_path = M.get()
  if not venv_path then
    return {}
  end
  return {
    python = {
      venvPath = paths.dirname(venv_path),
      venv = vim.fn.fnamemodify(venv_path, ":t"),
    },
  }
end

function M.restart_pyright()
  pcall(vim.cmd.LspRestart, "pyright")
end

function M.info()
  local venv = M.get()
  local python = M.python_executable()
  if venv then
    notify.info(string.format("venv: %s\npython: %s", venv, python), "kathi.python")
  else
    notify.warn(string.format("No venv found — using %s", python), "kathi.python")
  end
end

function M.pick()
  local current = M.get()
  local venvs = M.discover()
  local entries = vim.list_extend({}, venvs)
  table.insert(entries, "__manual__")

  require("telescope.pickers")
    .new({}, {
      prompt_title = "Select Python venv",
      finder = require("telescope.finders").new_table({
        results = entries,
        entry_maker = function(entry)
          if entry == "__manual__" then
            return {
              value = entry,
              display = "Enter path manually...",
              ordinal = "manual",
            }
          end
          local display = entry
          if entry == current then
            display = display .. " (current)"
          end
          return {
            value = entry,
            display = display,
            ordinal = display,
          }
        end,
      }),
      sorter = require("telescope.config").values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        local actions = require("telescope.actions")
        actions.select_default:replace(function()
          local selection = require("telescope.actions.state").get_selected_entry()
          actions.close(prompt_bufnr)
          if not selection then
            return
          end
          if selection.value == "__manual__" then
            local path = vim.fn.input("Venv path: ", current or "", "dir")
            if path and path ~= "" and M.set(path) then
              M.restart_pyright()
              notify.info("Venv set to " .. M.get(), "kathi.python")
            end
          elseif M.set(selection.value) then
            M.restart_pyright()
            notify.info("Venv set to " .. selection.value, "kathi.python")
          end
        end)
        return true
      end,
    })
    :find()
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true

  vim.api.nvim_create_user_command("KathiVenv", function()
    M.pick()
  end, { desc = "Select Python virtualenv for current project" })

  vim.api.nvim_create_user_command("KathiVenvInfo", function()
    M.info()
  end, { desc = "Show active Python virtualenv" })

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("KathiPythonVenv", { clear = true }),
    pattern = "python",
    callback = function()
      M.get()
    end,
  })
end

return M
