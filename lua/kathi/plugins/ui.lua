return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "catppuccin/nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lualine").setup({
        options = { theme = "catppuccin-nvim" },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = true,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = true,
  },
}
