local M = {}

function M.info(msg, title)
  vim.notify(msg, vim.log.levels.INFO, { title = title or "kathi" })
end

function M.warn(msg, title)
  vim.notify(msg, vim.log.levels.WARN, { title = title or "kathi" })
end

function M.error(msg, title)
  vim.notify(msg, vim.log.levels.ERROR, { title = title or "kathi" })
end

return M
