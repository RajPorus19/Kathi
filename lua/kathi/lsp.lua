-- LSP — native language server setup

local lspconfig = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

-- Set up Mason (LSP installer)
mason.setup()
mason_lspconfig.setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "ts_ls",
    "rust_analyzer",
    "gopls",
    "dartls",
    "bashls",
    "jsonls",
    "yamlls",
    "html",
    "cssls",
  },
  automatic_installation = true,
})

-- Shared on_attach for all LSP servers
local on_attach = function(client, bufnr)
  local map = vim.keymap.set
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Navigation (same as old gd/gy/gi/gr)
  map("n", "gd", vim.lsp.buf.definition, opts)
  map("n", "gy", vim.lsp.buf.type_definition, opts)
  map("n", "gi", vim.lsp.buf.implementation, opts)
  map("n", "gr", vim.lsp.buf.references, opts)

  -- Extra LSP goodies
  map("n", "K", vim.lsp.buf.hover, opts)
  map("n", "<leader>rn", vim.lsp.buf.rename, opts)
  map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  map("n", "[d", vim.diagnostic.goto_prev, opts)
  map("n", "]d", vim.diagnostic.goto_next, opts)
end

-- Capabilities for completion
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Set up each server
mason_lspconfig.setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end,
})
