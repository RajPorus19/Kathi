return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      vim.lsp.config("pyright", {
        before_init = function(_, config)
          config.settings = vim.tbl_deep_extend(
            "force",
            config.settings or {},
            require("kathi.stacks.python.venv").pyright_settings()
          )
        end,
      })

      require("mason-lspconfig").setup({
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
      })
    end,
  },
}
