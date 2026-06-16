return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
      "jay-babu/mason-nvim-dap.nvim",
    },
    ft = { "python" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "debugpy" },
        automatic_installation = true,
      })
      require("kathi.stacks.python").setup()
    end,
  },
}
