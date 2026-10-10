return {
  {
    "maxpaulus43/llama-cmp.nvim",
    opts = {
      model = "qwen2.5-coder:7b",
    },
    config = function(_, opts)
      require("llama-cmp").setup(opts)

      local llama = require("llama-cmp")

      local function define(name, desc, fn)
        if vim.fn.exists(":" .. name) == 0 then
          vim.api.nvim_create_user_command(name, fn, { desc = desc })
        end
      end

      define("AiOn", "Enable AI autocomplete", function()
        llama.enable()
      end)
      define("AiOff", "Disable AI autocomplete", function()
        llama.disable()
      end)
      define("AiToggle", "Toggle AI autocomplete", function()
        llama.toggle()
      end)
    end,
  },
}
