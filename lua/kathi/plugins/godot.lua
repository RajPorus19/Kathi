return {
  {
    "Mathijs-Bakker/godotdev.nvim",
    ft = { "gdscript", "gdshader", "gdresource", "csharp" },
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "nvim-treesitter/nvim-treesitter",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      require("godotdev").setup({
        csharp = false,
        treesitter = { auto_setup = false },
      })
      require("kathi.stacks.godot").setup()
    end,
  },
}
