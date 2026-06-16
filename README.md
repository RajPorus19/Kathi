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
│   ├── python.lua        # Django test runner + project detection
│   ├── dap.lua           # DAP configs (Django, Celery) + debug keymaps
│   └── plugins.lua       # Plugin specs + LSP/Mason/nvim-cmp
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

## Django / Celery — tests & debug (DAP)

When working on a Django project, Kathi can run unit tests and debug views, tests, and Celery tasks directly from the editor.

### Prerequisites

- A Django project with `manage.py` at the root (or a parent directory)
- Your virtualenv activated (`VIRTUAL_ENV` set) before launching Neovim
- `debugpy` is auto-installed via Mason on first use (`:Mason` → `debugpy`)
- For Celery debugging: `celery` installed in the project venv

### Workflow

1. Open a Python file in your Django project
2. Set a breakpoint with `<leader>db`
3. Launch a debug session:
   - `<leader>dD` — Django `runserver` (no reload, debug-friendly)
   - `<leader>dt` — debug the test under the cursor
   - `<leader>dC` — Celery worker (`--pool=solo` for breakpoints in tasks)
4. Inspect variables in the DAP UI panels (scopes, watches, stacks) or inline via virtual text
5. Use `<leader>de` to evaluate expressions in the REPL

### Test runner (`manage.py test`)

| Keymap | Action |
|--------|--------|
| `<leader>tt` | Run test at cursor (class, method, or file module) |
| `<leader>tf` | Run all tests in current file |
| `<leader>tr` | Rerun last test command |

Tests open in a horizontal terminal split. Fix code, then `<leader>tr` to rerun.

### Debug keymaps

| Keymap | Action |
|--------|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue / pick config |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>du` | Toggle DAP UI (variables, watches, stacks) |
| `<leader>de` | Eval expression |
| `<leader>dr` | Open debug REPL |
| `<leader>dx` | Terminate session |
| `<leader>dD` | Debug Django runserver |
| `<leader>dt` | Debug test at cursor |
| `<leader>dC` | Debug Celery worker |

### Tips

- `DJANGO_SETTINGS_MODULE` is read automatically from `manage.py`
- Celery app name (`-A`) is guessed from `celery.py` or settings; you'll be prompted if ambiguous
- For Celery task breakpoints, the worker must run with `--pool=solo` (configured automatically)

## Philosophy

- **Sharp.** No bloat. Every plugin earns its place.
- **Personal.** This is *my* config. Fork it, steal from it, but make it yours.
- **Evolving.** The old `init.vim` served for half a decade. This one will too — but in Lua.

