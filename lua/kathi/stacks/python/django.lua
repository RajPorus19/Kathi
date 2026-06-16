local notify = require("kathi.utils.notify")
local paths = require("kathi.utils.paths")

local M = {}

function M.find_manage_py(start_dir)
  local dir = start_dir or paths.cwd()
  while dir and dir ~= "/" do
    local candidate = dir .. "/manage.py"
    if vim.fn.filereadable(candidate) == 1 then
      return candidate, dir
    end
    dir = paths.dirname(dir)
  end
  return nil, nil
end

function M.project_root()
  local buf = vim.api.nvim_buf_get_name(0)
  local start = (#buf > 0 and vim.fn.fnamemodify(buf, ":p:h")) or paths.cwd()
  local _, root = M.find_manage_py(start)
  return root
end

function M.manage_py_path()
  local manage_py, root = M.find_manage_py(M.project_root() or paths.cwd())
  if not manage_py then
    notify.error("manage.py not found - open a Django project first", "kathi.python")
    return nil
  end
  return manage_py, root
end

function M.python_executable()
  return require("kathi.stacks.python.venv").python_executable()
end

function M.django_settings_module(root)
  root = root or M.project_root()
  if not root then
    return nil
  end

  local manage_py = root .. "/manage.py"
  if vim.fn.filereadable(manage_py) ~= 1 then
    return nil
  end

  local file = io.open(manage_py, "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()

  return content:match('DJANGO_SETTINGS_MODULE["%s]*,["%s]*([^"\']+)')
    or content:match("DJANGO_SETTINGS_MODULE['%s]*,['%s]*([^\"']+)")
end

function M.django_env()
  local root = M.project_root()
  local env = { PYTHONPATH = root or paths.cwd() }
  local settings = M.django_settings_module(root)
  if settings then
    env.DJANGO_SETTINGS_MODULE = settings
  end
  local venv = require("kathi.stacks.python.venv").get()
  if venv then
    env.VIRTUAL_ENV = venv
    env.PATH = venv .. "/bin:" .. (vim.env.PATH or "")
  end
  return env
end

function M.celery_app()
  local root = M.project_root()
  if not root then
    return vim.fn.input("Celery app (-A): ")
  end

  for _, path in ipairs(vim.fn.globpath(root, "**/celery.py", false, true)) do
    local rel = path:gsub("^" .. root .. "/", ""):gsub("/celery%.py$", ""):gsub("/", ".")
    if rel ~= "" and rel ~= "celery" and not rel:match("^%.") then
      return rel
    end
  end

  local settings = M.django_settings_module(root)
  if settings then
    return (settings:match("^(.+)%.settings") or settings:gsub("%.settings.*$", ""))
  end

  return vim.fn.input("Celery app (-A): ")
end

function M.file_to_module(filepath, root)
  root = root or M.project_root()
  if not root or not filepath then
    return nil
  end
  return filepath:gsub("^" .. root .. "/", ""):gsub("%.py$", ""):gsub("/", ".")
end

function M.test_target_at_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  local root = M.project_root()

  if filepath == "" or not root then
    notify.error("No Django project root found", "kathi.python")
    return nil
  end

  local module = M.file_to_module(filepath, root)
  if not module then
    return nil
  end

  local class_name, test_name

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

return M
