-- Autocommands

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local kathi_group = augroup("Kathi", { clear = true })

-- Normalize dotted/special filetypes so LSP health checks stay clean.
vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
  pattern = {
    [".*%.ya?ml%.docker%-compose"] = "yaml",
    [".*%.ya?ml%.gitlab"] = "yaml",
    [".*%.ya?ml%.helm%-values"] = "yaml",
  },
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = kathi_group,
  pattern = "*",
  callback = function()
    if not vim.bo.modifiable or vim.bo.binary or vim.bo.buftype ~= "" then
      return
    end
    pcall(vim.cmd, [[keeppatterns %s/\s\+$//e]])
  end,
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

-- LSP keymaps (reliable across all servers once attached).
autocmd("LspAttach", {
  group = kathi_group,
  callback = function(event)
    local map = vim.keymap.set
    local opts = { buffer = event.buf, noremap = true, silent = true }
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gy", vim.lsp.buf.type_definition, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    map("n", "[d", vim.diagnostic.goto_prev, opts)
    map("n", "]d", vim.diagnostic.goto_next, opts)
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
    -- Defer so async parser installs can finish; never error on open.
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(0) then
        return
      end
      local ok = pcall(vim.treesitter.start)
      if ok then
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end)
  end,
})
