# Python / Django / Celery stack

Kathi’s Python workflow covers general Python editing, Django projects, test running, virtualenv management, debugging, and formatting.

## When this stack is active

| Trigger | What loads |
|---------|------------|
| Open a `.py` file | `nvim-dap` + Python stack (`plugins/debug.lua`) |
| Open a `.py` file | Venv discovery (`venv.lua`) |
| Format on save / `:Format` | `conform.nvim` + `ruff` (`plugins/formatting.lua`) |
| LSP on Python buffers | `pyright` via Mason (`plugins/lsp.lua`) |

Django-specific features (tests, runserver debug, Celery) activate when a `manage.py` is found in an ancestor directory. Venv root detection also recognizes `pyproject.toml` and `.git`.

## Plugins

| Plugin | Role | Config file |
|--------|------|-------------|
| [pyright](https://github.com/microsoft/pyright) (Mason) | Python LSP — types, diagnostics, completion | `plugins/lsp.lua` |
| [ruff](https://github.com/astral-sh/ruff) (Mason) | Formatter via `conform.nvim` | `plugins/formatting.lua` |
| [djlint](https://github.com/djlint/djLint) (Mason) | Django HTML template formatter | `plugins/formatting.lua` |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug adapter protocol | `plugins/debug.lua` |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | Debug UI panels | `stacks/python/dap.lua` |
| [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python) | Python / Django DAP configs | `stacks/python/dap.lua` |
| [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Inline variable values while debugging | `stacks/python/dap.lua` |
| [debugpy](https://github.com/microsoft/debugpy) (Mason) | Python debugger backend | `plugins/debug.lua` |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting + test target parsing | `plugins/editor.lua` |

## Stack modules

| File | Purpose |
|------|---------|
| `init.lua` | Entrypoint — calls venv + DAP setup |
| `venv.lua` | Virtualenv discovery, `:KathiVenv`, Pyright venv settings |
| `django.lua` | `manage.py` detection, settings module, test target at cursor, Celery app name |
| `tests.lua` | `manage.py test` runner in a terminal split |
| `dap.lua` | DAP UI, launch configs, debug keymaps |

## Prerequisites

- Python 3 with a project virtualenv (`.venv`, `venv`, `env`, or `.env`)
- Activate your venv before launching Neovim, or pick one with `:KathiVenv`
- Django projects need `manage.py` at the project root (or a parent directory)
- For Celery debugging: `celery` installed in the project venv
- `debugpy` and `ruff` install automatically via Mason on first use

## Commands

| Command | Description |
|---------|-------------|
| `:KathiVenv` | Pick the active virtualenv (Telescope picker; persists to `.kathi/venv`) |
| `:KathiVenvInfo` | Show the current venv and Python executable |
| `:Format` | Format the current buffer (`ruff` for Python, `djlint` for Django HTML) |

Python buffers also format on save via `conform.nvim`.

Django HTML files (`djangohtml` filetype) are matched by path: `*/templates/*.html` or `*.djhtml`.

## Keybindings

Leader is `<Space>`.

### Tests (`manage.py test`)

Runs open in a horizontal terminal split.

| Key | Action |
|-----|--------|
| `<leader>tt` | Run test at cursor (class, method, or file module) |
| `<leader>tf` | Run all tests in the current file |
| `<leader>tr` | Rerun the last test command |

Test commands use `--keepdb -v 3` by default.

### Debug (DAP)

Loaded when you first open a Python file. Keymaps are **global** while the DAP plugin is loaded.

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint (prompts for expression) |
| `<leader>dc` | Continue / pick launch config |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>du` | Toggle DAP UI |
| `<leader>de` | Evaluate expression |
| `<leader>dr` | Open debug REPL |
| `<leader>dx` | Terminate session |
| `<leader>dD` | Debug Django `runserver` (`--noreload`) |
| `<leader>dt` | Debug test at cursor |
| `<leader>dC` | Debug Celery worker (`--pool=solo`) |

### DAP launch configurations

Available when you press `<leader>dc` or start a session:

| Config name | What it does |
|-------------|--------------|
| Django: runserver | `manage.py runserver --noreload` |
| Django: test (cursor) | `manage.py test --keepdb -v 3 <target>` |
| Celery: worker | `celery -A <app> worker -l info --pool=solo` |
| Python: current file | Run `${file}` directly |

`DJANGO_SETTINGS_MODULE` is read from `manage.py`. Celery app name (`-A`) is guessed from `celery.py` or settings; you’ll be prompted if ambiguous.

### LSP (Python buffers)

Shared across all stacks — attached automatically on `LspAttach`:

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

### Plain Python

1. Open a `.py` file in your project
2. Run `:KathiVenv` if Pyright isn’t using the right interpreter
3. Edit with LSP completion and diagnostics; save to format with `ruff`
4. Set breakpoints with `<leader>db`, then `<leader>dc` and pick **Python: current file**

### Django

1. Open any file under a project with `manage.py`
2. Select venv with `:KathiVenv` if needed
3. Run tests with `<leader>tt` / `<leader>tf`; fix and `<leader>tr` to rerun
4. Debug a view: `<leader>db` on a line, `<leader>dD` to start runserver, hit the endpoint
5. Debug a test: cursor on `test_*`, `<leader>dt`

### Celery

1. Set a breakpoint inside a task function
2. `<leader>dC` to start a solo-pool worker
3. Trigger the task from Django shell, admin, or an API call

## Tips

- Venv choice is stored per project in `.kathi/venv` (gitignored in most projects)
- `vim-rooter` changes cwd to the nearest `manage.py`, `.git`, or `Makefile`
- For Celery breakpoints, the worker **must** use `--pool=solo` (configured automatically in the DAP launch config)
- If Pyright shows the wrong interpreter after changing venv, it restarts automatically via `:KathiVenv`
