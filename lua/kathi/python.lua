-- Backward-compatible entrypoint for Python stack helpers.
local django = require("kathi.stacks.python.django")
local tests = require("kathi.stacks.python.tests")

return vim.tbl_extend("force", django, tests)
