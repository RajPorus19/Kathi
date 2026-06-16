# Old Config — The Relic

This `init.vim` is my original Neovim configuration. It hasn't been touched in about five years.

Not because I was lazy. Not because I didn't care. But because **it worked.**

Every keybinding was muscle memory. Every plugin — `coc.nvim`, `NERDTree`, `fzf`, `vim-fugitive` — did exactly what it was supposed to. There was no reason to change something that wasn't broken. For half a decade, this file sat quietly in `~/.config/nvim/` and just… worked.

But the ecosystem moved on.

- **Lua became the first-class citizen.** Vimscript still runs, but the community — plugin authors, Neovim core, everyone — shifted to Lua for performance, readability, and extensibility.
- **`coc.nvim`** gave way to native LSP (`nvim-lspconfig` + `mason`).
- **`NERDTree`** evolved into `neo-tree`.
- **`fzf.vim`** was reimagined as `telescope.nvim`.
- Plugin managers moved from `vim-plug` to `lazy.nvim`.

So here it is, preserved in the `old-config/` folder. A snapshot of a simpler time. A working setup that served faithfully — and now rests, replaced by a sharper tool.

> *"If it ain't broke, don't fix it" — until the world changes around you.*
