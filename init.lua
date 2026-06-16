-- ═══════════════════════════════════════════════
-- Kathi 🪚 — A developer's Neovim config, sharp and personal.
-- ═══════════════════════════════════════════════

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load config modules
require("kathi.options")
require("kathi.keymaps")
require("kathi.autocmds")
require("kathi.plugins")
require("kathi.lsp")
