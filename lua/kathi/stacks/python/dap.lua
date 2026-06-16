local M = {}

function M.setup()
  local dap = require("dap")
  local dapui = require("dapui")
  local django = require("kathi.stacks.python.django")
  local tests = require("kathi.stacks.python.tests")

  dapui.setup({
    icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.33 },
          { id = "breakpoints", size = 0.17 },
          { id = "stacks", size = 0.25 },
          { id = "watches", size = 0.25 },
        },
        size = 0.33,
        position = "right",
      },
      {
        elements = {
          { id = "repl", size = 0.5 },
          { id = "console", size = 0.5 },
        },
        size = 0.25,
        position = "bottom",
      },
    },
  })

  require("nvim-dap-virtual-text").setup({
    enabled = true,
    enabled_commands = true,
    highlight_changed_variables = true,
    highlight_newly_created = true,
  })

  dap.listeners.after.event_initialized["kathi_dapui"] = function()
    dapui.open({ reset = true })
  end
  dap.listeners.before.event_terminated["kathi_dapui"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["kathi_dapui"] = function()
    dapui.close()
  end

  local ok, registry = pcall(require, "mason-registry")
  if ok then
    local pkg = registry.get_package("debugpy")
    if pkg:is_installed() then
      require("dap-python").setup(pkg:get_install_path() .. "/venv/bin/python")
    else
      require("dap-python").setup("debugpy")
    end
  else
    require("dap-python").setup("debugpy")
  end

  local function django_launch(name, args_fn)
    return {
      type = "python",
      request = "launch",
      name = name,
      program = function()
        return django.manage_py_path()
      end,
      args = args_fn,
      django = true,
      justMyCode = false,
      env = function()
        return django.django_env()
      end,
      cwd = function()
        return django.project_root()
      end,
    }
  end

  dap.configurations.python = {
    django_launch("Django: runserver", function()
      return { "runserver", "--noreload" }
    end),
    django_launch("Django: test (cursor)", function()
      local target = django.test_target_at_cursor()
      return target and { "test", target } or { "test" }
    end),
    {
      type = "python",
      request = "launch",
      name = "Celery: worker",
      module = "celery",
      args = function()
        return {
          "-A",
          django.celery_app(),
          "worker",
          "-l",
          "info",
          "--pool=solo",
        }
      end,
      justMyCode = false,
      env = function()
        return django.django_env()
      end,
      cwd = function()
        return django.project_root()
      end,
    },
    {
      type = "python",
      request = "launch",
      name = "Python: current file",
      program = "${file}",
      justMyCode = false,
      cwd = "${workspaceFolder}",
    },
  }

  M.setup_keymaps(dap, dapui, tests)
end

function M.setup_keymaps(dap, dapui, tests)
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }

  local function pick_and_run(name)
    for _, config in ipairs(dap.configurations.python) do
      if config.name == name then
        dap.run(config)
        return
      end
    end
    dap.continue()
  end

  map("n", "<leader>db", dap.toggle_breakpoint, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
  map("n", "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, vim.tbl_extend("force", opts, { desc = "Conditional breakpoint" }))
  map("n", "<leader>dc", dap.continue, vim.tbl_extend("force", opts, { desc = "Debug continue" }))
  map("n", "<leader>do", dap.step_over, vim.tbl_extend("force", opts, { desc = "Step over" }))
  map("n", "<leader>di", dap.step_into, vim.tbl_extend("force", opts, { desc = "Step into" }))
  map("n", "<leader>dO", dap.step_out, vim.tbl_extend("force", opts, { desc = "Step out" }))
  map("n", "<leader>du", dapui.toggle, vim.tbl_extend("force", opts, { desc = "Toggle DAP UI" }))
  map("n", "<leader>de", dapui.eval, vim.tbl_extend("force", opts, { desc = "Eval expression" }))
  map("n", "<leader>dr", dap.repl.open, vim.tbl_extend("force", opts, { desc = "Debug REPL" }))
  map("n", "<leader>dx", dap.terminate, vim.tbl_extend("force", opts, { desc = "Terminate debug" }))

  map("n", "<leader>dD", function()
    pick_and_run("Django: runserver")
  end, vim.tbl_extend("force", opts, { desc = "Debug Django runserver" }))
  map("n", "<leader>dt", function()
    pick_and_run("Django: test (cursor)")
  end, vim.tbl_extend("force", opts, { desc = "Debug test at cursor" }))
  map("n", "<leader>dC", function()
    pick_and_run("Celery: worker")
  end, vim.tbl_extend("force", opts, { desc = "Debug Celery worker" }))

  map("n", "<leader>tt", tests.run_test_cursor, vim.tbl_extend("force", opts, { desc = "Run test at cursor" }))
  map("n", "<leader>tf", tests.run_test_file, vim.tbl_extend("force", opts, { desc = "Run test file" }))
  map("n", "<leader>tr", tests.rerun_last_test, vim.tbl_extend("force", opts, { desc = "Rerun last test" }))
end

return M
