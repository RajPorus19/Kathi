local M = {}

function M.setup()
  require("kathi.stacks.python.venv").setup()
  require("kathi.stacks.python.dap").setup()
end

return M
