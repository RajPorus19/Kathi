local M = {}

function M.dirname(path)
  return vim.fn.fnamemodify(path, ":h")
end

function M.join(...)
  return table.concat({ ... }, "/")
end

function M.cwd()
  return vim.loop.cwd()
end

return M
