# Godot / GDScript stack

Kathi integrates with [godotdev.nvim](https://github.com/Mathijs-Bakker/godotdev.nvim) for Godot 4 development: GDScript, GDShader, scene resources, and optional C# scripts.

## When this stack is active

The Godot plugin lazy-loads when you open a file with one of these filetypes:

- `gdscript` (`.gd`)
- `gdshader` (`.gdshader`)
- `gdresource` (`.tres`, `.tscn`)
- `csharp` (`.cs`)

**Godot keymaps** are buffer-local and only attach when **both** are true:

1. The buffer has a Godot-related filetype (above)
2. A `project.godot` file exists in an ancestor directory

Editing a standalone `.gd` file outside a project gets syntax highlighting and LSP (if Godot editor is running) but **no** `<leader>g*` keymaps. Editing `.cs` in a non-Godot repo does not get Godot keymaps.

## Plugins

| Plugin | Role | Config file |
|--------|------|-------------|
| [godotdev.nvim](https://github.com/Mathijs-Bakker/godotdev.nvim) | LSP bridge, docs, DAP, formatting, run commands | `plugins/godot.lua` |
| Godot editor (external) | GDScript LSP over TCP (port 6005) | Must be running with project open |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug adapter protocol | `plugins/godot.lua` (dependency) |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | Debug UI panels | `stacks/godot/init.lua` |
| [netcoredbg](https://github.com/Samsung/netcoredbg) (Mason) | C# debugger for Godot | `stacks/godot/init.lua` |
| [csharp_ls](https://github.com/razzmatazz/csharp-language-server) (Mason) | C# LSP (user-managed; godotdev checks tooling) | `plugins/lsp.lua` |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | `gdscript`, `godot_resource`, `gdshader` parsers | `plugins/editor.lua` |

GDScript LSP is **not** a Mason server — it runs inside the Godot editor.

## Stack modules

| File | Purpose |
|------|---------|
| `init.lua` | Project-scoped buffer keymaps, DAP UI setup, `netcoredbg` install |

## Prerequisites

### System

- Godot 4.x on `PATH` as `godot`
- `curl` (for in-editor class reference docs)
- [gdscript-formatter](https://github.com/GDQuest/GDScript-formatter) on `PATH` (default formatter)
- `tree-sitter` CLI (Kathi-wide requirement)

### C# (optional)

- .NET SDK (`dotnet`)
- `csharp_ls` and `netcoredbg` via Mason (installed on first Godot file open)

### Godot editor (one-time)

Enable **Advanced Settings** in Editor Settings, then:

1. **Network → Language Server** — enable TCP LSP; enable **Use Thread**
2. **Text Editor → Behavior** — **Auto Reload Scripts on External Change**
3. **Interface → Editor** — **Save on Focus Loss**
4. **Text Editor → External** — configure Neovim as external editor ([setup guide](https://github.com/Mathijs-Bakker/godotdev.nvim/blob/master/doc/neovim-external-editor-setup.md))

## Commands

### godotdev.nvim

| Command | Description |
|---------|-------------|
| `:KathiGodotDocs [Class]` | Class reference (RST-first; recommended over `:GodotDocs`) |
| `:GodotDocs [Class]` | Class reference docs (float; uses symbol under cursor if omitted) |
| `:GodotDocsFloat [Class]` | Docs in a floating window |
| `:GodotDocsBuffer [Class]` | Docs in a side buffer |
| `:GodotDocsBrowser [Class]` | Open docs in system browser |
| `:GodotDocsCursor` | Docs for symbol under cursor |
| `:GodotReconnectLSP` | Reconnect all Godot buffers to the editor LSP |
| `:GodotToggleInlineHints` | Toggle inlay hints (GDScript) |
| `:GodotRunProject` | Run the current Godot project |
| `:GodotRunCurrentScene` | Run scene attached to current script |
| `:GodotRunScene {path}` | Run a specific scene |
| `:GodotRunScenePicker` | Pick a scene with Telescope |
| `:GodotSceneTree [path]` | Open static scene tree pane |
| `:GodotSceneTreeRefresh` | Refresh scene tree pane |
| `:GodotStartEditorServer` | Start Neovim server for Godot external editor |
| `:checkhealth godotdev` | Verify LSP, debugger, formatter, and C# tooling |

`.gd` files are auto-formatted on save by godotdev (via `gdscript-formatter`).

## Keybindings

Leader is `<Space>`. All Godot workflow maps below are **buffer-local** and require a `project.godot` ancestor.

### Docs and LSP

| Key | Action | Active on |
|-----|--------|-----------|
| `gK` | Godot class reference (`:KathiGodotDocs`) | All Godot project buffers |
| `K` | LSP hover (global, all stacks) | Any LSP-attached buffer |
| `<leader>gl` | Reconnect LSP | All Godot project buffers |
| `<leader>gh` | Toggle inline hints | `gdscript` only |

### Run and scene tree

| Key | Action | Active on |
|-----|--------|-----------|
| `<leader>gp` | Run project | All Godot project buffers |
| `<leader>gs` | Run current scene | `.gd` / `.cs` script buffers |
| `<leader>gS` | Scene picker (Telescope) | All Godot project buffers |
| `<leader>gt` | Scene tree pane | All Godot project buffers |
| `<leader>gR` | Refresh scene tree | All Godot project buffers |

### Debug (DAP)

Buffer-local on `.gd` and `.cs` files inside a Godot project. These override the global Python DAP maps **only in that buffer**.

| Key | Action |
|-----|--------|
| `<leader>gD` | Start Godot debug session (`dap.continue`) |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>du` | Toggle DAP UI |
| `<leader>de` | Evaluate expression |
| `<leader>dx` | Terminate session |

godotdev registers Godot DAP launch configs; pick one when prompted by `<leader>dc` or `<leader>gD`.

### LSP navigation (all stacks)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gy` | Go to type definition |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `[d` / `]d` | Previous / next diagnostic |

## Typical workflow

1. Open your project in **Godot 4** (LSP must be running)
2. Open the same project root in Neovim (`project.godot` present)
3. Edit a `.gd` file — LSP attaches over TCP to the Godot editor
4. `K` for hover on a symbol, `gK` for official class reference docs
5. `<leader>gt` to inspect the scene tree; `<leader>gs` to run the current scene
6. `<leader>db` + `<leader>gD` to debug with DAP
7. If LSP disconnects: `<leader>gl` or `:GodotReconnectLSP`
8. Verify setup anytime: `:checkhealth godotdev`

## Tips

- `vim-rooter` recognizes `project.godot` as a project root
- Godot’s LSP runs in the editor — keep Godot open with your project loaded
- Optional [godotdev.nvim-node-copy](https://github.com/Mathijs-Bakker/godotdev.nvim-node-copy) addon lets you copy node paths from Godot into Neovim
- C# LSP is configured by Mason (`csharp_ls`); godotdev only validates and integrates debugging
- Prefer `gdscript-formatter` over `gdformat` (godotdev default; required by the node-copy addon)

## Troubleshooting

| Problem | Try |
|---------|-----|
| Docs never find anything | See [Why docs fail](#why-docs-lookup-fails) below |
| No completion / diagnostics | Godot editor open? LSP enabled? Run `<leader>gl` |
| No Godot keymaps | Is `project.godot` in a parent directory? |
| Formatter warning | Install `gdscript-formatter` and ensure it’s on `PATH` |
| C# debug fails | Run `:Mason` and install `netcoredbg`; check `dotnet --version` |
| Docs don’t load | Ensure `curl` is installed and network is available |

### Why docs lookup fails

`:GodotDocs` / `gK` only look up **Godot class names** (PascalCase types like `Node`, `CharacterBody2D`), not methods, properties, or variables.

- Cursor on `move_and_slide`, `get_node`, or `player` → will not match a class page. Use `K` for LSP hover on those.
- Cursor on `Node2D` inside `extends Node2D` → should work.

**Rate limiting:** godotdev.nvim's `:GodotDocs` verifies pages by fetching HTML from `docs.godotengine.org` first. That host often returns HTTP 429 (rate limit), so lookups fail even when the GitHub RST source is reachable.

Kathi's `gK` and `:KathiGodotDocs` bypass that check and fetch RST from GitHub directly, falling back to your browser if needed. Prefer those over `:GodotDocs`.

Quick test:

```vim
:KathiGodotDocs Node
```

If that works but `gK` does not, your cursor is probably not on a class name.

