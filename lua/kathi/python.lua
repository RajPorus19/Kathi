-- Django / Celery helpers — test runner + DAP project detection

local M = {}

M.last_test_cmd = nil

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "kathi.python" })
end

--- Walk upward from start_dir until manage.py is found.
function M.find_manage_py(start_dir)
  local dir = start_dir or vim.loop.cwd()
  while dir and dir ~= "/" do
    local candidate = dir .. "/manage.py"
    if vim.fn.filereadable(candidate) == 1 then
      return candidate, dir
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil, nil
end

--- Project root (directory containing manage.py), from buffer or cwd.
function M.project_root()
  local buf = vim.api.nvim_buf_get_name(0)
  local start = (#buf > 0 and vim.fn.fnamemodify(buf, ":p:h")) or vim.loop.cwd()
  local _, root = M.find_manage_py(start)
  return root
end

function M.manage_py_path()
  local manage_py, root = M.find_manage_py(M.project_root() or vim.loop.cwd())
  if not manage_py then
    notify("manage.py not found — open a Django project first", vim.log.levels.ERROR)
    return nil
  end
  return manage_py, root
end

--- Prefer active venv, then python3 on PATH.
function M.python_executable()
  local venv = vim.env.VIRTUAL_ENV
  if venv and venv ~= "" then
    local bin = venv .. "/bin/python"
    if vim.fn.executable(bin) == 1 then
      return bin
    end
  end
  if vim.fn.executable("python3") == 1 then
    return "python3"
  end
  return "python"
end

--- Parse DJANGO_SETTINGS_MODULE from manage.py.
function M.django_settings_module(root)
  root = root or M.project_root()
  if not root then
    return nil
  end
  local manage_py = root .. "/manage.py"
  if vim.fn.filereadable(manage_py) ~= 1 then
    return nil
  end
  local f = io.open(manage_py, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  local settings = content:match('DJANGO_SETTINGS_MODULE["%s]*,["%s]*([^"\']+)')
    or content:match("DJANGO_SETTINGS_MODULE['%s]*,['%s]*([^\"']+)")
  return settings
end

--- Env vars for Django debug sessions.
function M.django_env()
  local root = M.project_root()
  local env = {
    PYTHONPATH = root or vim.loop.cwd(),
  }
  local settings = M.django_settings_module(root)
  if settings then
    env.DJANGO_SETTINGS_MODULE = settings
  end
  if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
    env.VIRTUAL_ENV = vim.env.VIRTUAL_ENV
    env.PATH = vim.env.VIRTUAL_ENV .. "/bin:" .. (vim.env.PATH or "")
  end
  return env
end

--- Guess Celery app name from <project>/celery.py or settings module package.
function M.celery_app()
  local root = M.project_root()
  if not root then
    return vim.fn.input("Celery app (-A): ")
  end

  -- Look for celery.py in project packages
  local handle = io.popen('find "' .. root .. '" -maxdepth 3 -name "celery.py" 2>/dev/null')
  if handle then
    local result = handle:read("*a")
    handle:close()
    for line in result:gmatch("[^\n]+") do
      local rel = line:gsub("^" .. root .. "/", ""):gsub("/celery%.py$", ""):gsub("/", ".")
      if rel ~= "" and rel ~= "celery" then
        return rel
      end
    end
  end

  local settings = M.django_settings_module(root)
  if settings then
    return (settings:match("^(.+)%.settings") or settings:gsub("%.settings.*$", ""))
  end

  return vim.fn.input("Celery app (-A): ")
end

--- Convert absolute file path to Python module dotted path.
function M.file_to_module(filepath, root)
  root = root or M.project_root()
  if not root or not filepath then
    return nil
  end
  local rel = filepath:gsub("^" .. root .. "/", ""):gsub("%.py$", ""):gsub("/", ".")
  return rel
end

--- Nearest enclosing `class` and `def test_*` above cursor.
function M.test_target_at_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  local root = M.project_root()

  if filepath == "" or not root then
    notify("No Django project root found", vim.log.levels.ERROR)
    return nil
  end

  local module = M.file_to_module(filepath, root)
  if not module then
    return nil
  end

  local class_name, test_name

  -- Treesitter: walk up from cursor node
  local ok = pcall(function()
    local node = vim.treesitter.get_node_at_cursor()
    while node do
      local ntype = node:type()
      if ntype == "function_definition" and not test_name then
        local name_node = node:field("name")[1]
        if name_node then
          local fn = vim.treesitter.get_node_text(name_node, buf)
          if fn:match("^test_") then
            test_name = fn
          end
        end
      elseif ntype == "class_definition" and not class_name then
        local name_node = node:field("name")[1]
        if name_node then
          class_name = vim.treesitter.get_node_text(name_node, buf)
        end
      end
      node = node:parent()
    end
  end)

  -- Regex fallback
  if not ok or (not class_name and not test_name) then
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(buf, 0, row, false)
    for i = #lines, 1, -1 do
      local line = lines[i]
      if not test_name then
        local fn = line:match("^%s*def%s+(test_%w+)")
        if fn then
          test_name = fn
        end
      end
      if not class_name then
        local cls = line:match("^class%s+(%w+)")
        if cls then
          class_name = cls
        end
      end
      if class_name and test_name then
        break
      end
    end
  end

  if test_name and class_name then
    return module .. "." .. class_name .. "." .. test_name
  elseif class_name then
    return module .. "." .. class_name
  end
  return module
end

--- Run a shell command in a horizontal terminal split.
function M.run_in_terminal(cmd, title)
  if not cmd or cmd == "" then
    return
  end
  M.last_test_cmd = cmd
  vim.cmd("split")
  vim.cmd("terminal " .. cmd)
  vim.cmd("startinsert")
  if title then
    vim.bo.buflisted = false
  end
end

--- Build and run `manage.py test <target>`.
function M.run_test(target)
  local manage_py, root = M.manage_py_path()
  if not manage_py then
    return
  end
  local python = M.python_executable()
  local cmd = string.format('cd "%s" && %s "%s" test %s', root, python, manage_py, target or "")
  M.run_in_terminal(cmd)
end

function M.run_test_file()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    notify("No file open", vim.log.levels.ERROR)
    return
  end
  local module = M.file_to_module(filepath, M.project_root())
  if not module then
    notify("Could not resolve test module", vim.log.levels.ERROR)
    return
  end
  M.run_test(module)
end

function M.run_test_cursor()
  local target = M.test_target_at_cursor()
  if not target then
    notify("Could not resolve test target at cursor", vim.log.levels.ERROR)
    return
  end
  M.run_test(target)
end

function M.rerun_last_test()
  if not M.last_test_cmd then
    notify("No previous test command to rerun", vim.log.levels.WARN)
    return
  end
  M.run_in_terminal(M.last_test_cmd)
end

return M
