# Kathi language stacks

Stacks are language- or workflow-specific modules under `lua/kathi/stacks/`. Each stack wires plugins, commands, and keymaps for a particular ecosystem. Stack keymaps live inside the stack module — not in `core/keymaps.lua`.

| Stack | Path | When it loads |
|-------|------|---------------|
| [Python / Django / Celery](python/README.md) | `stacks/python/` | Opening a `.py` file (DAP plugin) or on format/LSP setup |
| [Godot / GDScript](godot/README.md) | `stacks/godot/` | Opening `.gd`, `.gdshader`, `.gdresource`, or `.cs` in a Godot project |

## Shared editor features

These apply in every stack once LSP attaches (see `core/autocmds.lua`):

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gy` | Go to type definition |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `[d` / `]d` | Previous / next diagnostic |

Global editor keymaps (`<leader>sp`, `<leader>op`, etc.) are documented in the root [README.md](../../../../README.md).

## Adding a new stack

1. Create `lua/kathi/stacks/<name>/init.lua` with a `setup()` entrypoint.
2. Add a `README.md` in the same folder documenting plugins, commands, and keymaps.
3. Load the stack from a lazy.nvim plugin spec (see `plugins/debug.lua` or `plugins/godot.lua`).
4. Keep stack-specific keymaps buffer-local or project-scoped when possible.
