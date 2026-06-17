return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = { width = 35 },
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          preview = {
            treesitter = false,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      telescope.load_extension("fzf")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    init = function()
      if vim.fn.executable("tree-sitter") ~= 1 then
        return
      end
      require("nvim-treesitter").install({
        "lua", "vim", "vimdoc",
        "python", "javascript", "typescript",
        "html", "css", "json", "yaml",
        "markdown", "markdown_inline",
        "bash", "c", "cpp", "rust", "go",
        "dart",
        "gdscript", "godot_resource", "gdshader",
      })
    end,
  },
  {
    "airblade/vim-rooter",
    init = function()
      vim.g.rooter_patterns = { ".git", "Makefile", "manage.py", "project.godot" }
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true,
  },
}
