-- Keymaps — muscle memory, Lua edition

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ── Window management ──
map("n", "<leader>ot", ":split | terminal<CR>", { desc = "Open terminal (horizontal)" })
map("n", "<leader>wn", ":vsplit | enew<CR>", { desc = "New vertical split" })

-- Resize windows
map("n", "<C-h>", ":vertical resize +5<CR>", opts)
map("n", "<C-j>", ":resize +5<CR>", opts)
map("n", "<C-k>", ":resize -5<CR>", opts)
map("n", "<C-l>", ":vertical resize -5<CR>", opts)

-- Navigate windows
map("n", "<leader>wh", "<C-w>h", { desc = "Window ←" })
map("n", "<leader>wj", "<C-w>j", { desc = "Window ↓" })
map("n", "<leader>wk", "<C-w>k", { desc = "Window ↑" })
map("n", "<leader>wl", "<C-w>l", { desc = "Window →" })

-- Terminal escape
map("t", "<A-h>", "<C-\\><C-N><C-w>h", opts)
map("t", "<A-j>", "<C-\\><C-N><C-w>j", opts)
map("t", "<A-k>", "<C-\\><C-N><C-w>k", opts)
map("t", "<A-l>", "<C-\\><C-N><C-w>l", opts)

-- ── LSP ──
-- gd, gy, gi, gr mapped in autocmds.lua on LspAttach

-- ── Telescope ──
map("n", "<leader>sp", "<cmd>Telescope live_grep<CR>", { desc = "Search project" })
map("n", "<leader>bi", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
map("n", "<leader><leader>", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>:", "<cmd>Telescope commands<CR>", { desc = "Commands" })
map("n", "<leader>sm", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search buffer" })
map("n", "<leader>ht", "<cmd>Telescope colorscheme<CR>", { desc = "Colorschemes" })
map("n", "<leader>hm", "<cmd>Telescope keymaps<CR>", { desc = "Keymaps" })

-- ── Neo-tree ──
map("n", "<leader>op", "<cmd>Neotree toggle<CR>", { desc = "Toggle file tree" })

-- ── Git ──
map("n", "<leader>gg", "<cmd>Neogit<CR>", { desc = "Git status" })

-- ── Neovide ──
map("n", "<F1>", ":set guifont=Source\\ Code\\ Pro:h25<CR>", { desc = "Bigger font" })
