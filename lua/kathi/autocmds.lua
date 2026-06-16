-- Autocommands

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local kathi_group = augroup("Kathi", { clear = true })

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = kathi_group,
  pattern = "*",
  command = "%s/\\s\\+$//e",
})

-- Return to last edit position on open
autocmd("BufReadPost", {
  group = kathi_group,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, { mark[1], 0 })
    end
  end,
})

-- Highlight yanked text
autocmd("TextYankPost", {
  group = kathi_group,
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Treesitter highlighting and indentation
autocmd("FileType", {
  group = kathi_group,
  pattern = {
    "lua", "vim", "help",
    "python", "javascript", "typescript",
    "html", "css", "json", "yaml", "markdown",
    "bash", "sh", "c", "cpp", "rust", "go", "dart",
  },
  callback = function()
    vim.treesitter.start()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
