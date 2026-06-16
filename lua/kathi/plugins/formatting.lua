return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = { "ruff", "djlint" },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    dependencies = {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("kathi.stacks.python.venv").setup()

      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_format" },
          djangohtml = { "djlint" },
        },
        format_on_save = function(bufnr)
          local ft = vim.bo[bufnr].filetype
          return ft == "python" or ft == "djangohtml"
        end,
      })

      vim.api.nvim_create_user_command("Format", function()
        require("conform").format({ async = true, lsp_fallback = false })
      end, { desc = "Format current buffer (ruff / djlint)" })
    end,
  },
}
