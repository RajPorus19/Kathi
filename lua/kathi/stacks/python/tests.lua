local notify = require("kathi.utils.notify")
local django = require("kathi.stacks.python.django")

local M = {
  last_test_cmd = nil,
  default_flags = "--keepdb -v 3",
}

function M.run_in_terminal(cmd)
  if not cmd or cmd == "" then
    return
  end
  M.last_test_cmd = cmd
  vim.cmd("split")
  vim.cmd("terminal " .. cmd)
  vim.cmd("startinsert")
end

function M.run_test(target)
  local manage_py, root = django.manage_py_path()
  if not manage_py then
    return
  end
  if not target or target == "" then
    notify.error("Empty test target — place cursor on a test or open a test file", "kathi.python")
    return
  end
  local python = django.python_executable()
  local cmd = string.format(
    'cd "%s" && %s "%s" test %s %s',
    root,
    python,
    manage_py,
    M.default_flags,
    target
  )
  M.run_in_terminal(cmd)
end

function M.run_test_file()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    notify.error("No file open", "kathi.python")
    return
  end
  local module = django.file_to_module(filepath, django.project_root())
  if not module then
    notify.error("Could not resolve test module", "kathi.python")
    return
  end
  M.run_test(module)
end

function M.run_test_cursor()
  local target = django.test_target_at_cursor()
  if not target then
    notify.error("Could not resolve test target at cursor", "kathi.python")
    return
  end
  M.run_test(target)
end

function M.rerun_last_test()
  if not M.last_test_cmd then
    notify.warn("No previous test command to rerun", "kathi.python")
    return
  end
  M.run_in_terminal(M.last_test_cmd)
end

return M
