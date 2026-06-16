-- Options — general Neovim settings

local opt = vim.opt

-- Providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Appearance
opt.syntax = "on"
opt.termguicolors = true
opt.background = "dark"
opt.cursorline = true
opt.colorcolumn = "80"
opt.signcolumn = "yes"
opt.number = true
opt.relativenumber = true

-- Indentation
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Search
opt.smartcase = true
opt.ignorecase = true

-- Clipboard
opt.clipboard:append("unnamedplus")

-- UI
opt.guifont = "Source Code Pro:h20"
opt.showmode = false
opt.scrolloff = 8

-- Performance
opt.updatetime = 50
opt.timeoutlen = 300
