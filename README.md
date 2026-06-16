# 🔪 Kathi

**கத்தி** (Tamil: *knife*)

Just as a cook needs a sharp, trusted **kathi** to work with precision and speed, a developer needs an editor that's been honed to *their* hand. This repository is my kathi : a Neovim configuration sharpened over years of daily use, now reforged in Lua for the modern era.

## What's Inside

```
├── init.lua              # Entry point — bootstraps lazy.nvim, loads config
├── lua/kathi/
│   ├── options.lua       # General Neovim settings
│   ├── keymaps.lua       # All keybindings (muscle memory, preserved)
│   ├── autocmds.lua      # Autocommands (whitespace cleanup, cursor restore, etc.)
│   └── plugins.lua       # Plugin specs + LSP/Mason/nvim-cmp setup (lazy.nvim)
└── old-config/
    ├── init.vim          # The original Vimscript config (2019–2024)
    └── LEGACY.md         # Why it stayed untouched for 5 years
```

## Key Design Decisions

| Aspect | Old Way | New Way |
|--------|---------|---------|
| Plugin manager | `vim-plug` | `lazy.nvim` |
| Completion/LSP | `coc.nvim` | Native LSP + `nvim-cmp` |
| File tree | `NERDTree` | `neo-tree` |
| Fuzzy finder | `fzf.vim` | `telescope.nvim` |
| Git | `vim-fugitive` | `neogit` + `gitsigns` |
| Theme | `nord` | `catppuccin` (mocha) |
| Config language | Vimscript | Lua |

All the original keybindings (`<leader>op` for file tree, `<leader>sp` for search, `gd`/`gr` for LSP navigation, `<C-hjkl>` for window resizing, etc.) have been preserved.

## Installation

### Prerequisites

Neovim 0.12+ with `git` installed. For Treesitter parsers (new `nvim-treesitter` main branch), you also need:

```bash
brew install tree-sitter
```

Python provider is kept enabled by default. If you want Python-powered plugins, install:

```bash
python3 -m pip install --user pynvim
```

### Setup

```bash
# Clone into your Neovim config directory
git clone https://github.com/RajPorus19/Kathi.git ~/.config/nvim

# Launch Neovim — lazy.nvim will auto-install and bootstrap everything
nvim
```

On first launch, `lazy.nvim` will install itself, then all plugins and Mason LSP servers will be fetched automatically. Just wait for the install to finish and you're ready.

If plugins don't appear after cloning, run `:Lazy sync` inside Neovim.
Then update Treesitter parsers manually with `:TSUpdate`.

## Philosophy

- **Sharp.** No bloat. Every plugin earns its place.
- **Personal.** This is *my* config. Fork it, steal from it, but make it yours.
- **Evolving.** The old `init.vim` served for half a decade. This one will too — but in Lua.

