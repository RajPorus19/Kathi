local M = {}

local groups = {
  require("kathi.plugins.lsp"),
  require("kathi.plugins.completion"),
  require("kathi.plugins.llama"),
  require("kathi.plugins.editor"),
  require("kathi.plugins.formatting"),
  require("kathi.plugins.ui"),
  require("kathi.plugins.git"),
  require("kathi.plugins.debug"),
  require("kathi.plugins.godot"),
}

for _, group in ipairs(groups) do
  vim.list_extend(M, group)
end

return M
