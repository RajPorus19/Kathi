local notify = require("kathi.utils.notify")

local M = {}

local function godotdev_docs_modules()
  local ok_fetch, fetch = pcall(require, "godotdev.docs.fetch")
  local ok_render, render = pcall(require, "godotdev.docs.render")
  local ok_common, common = pcall(require, "godotdev.docs.common")
  if not (ok_fetch and ok_render and ok_common) then
    return nil
  end
  return fetch, render, common
end

function M.extract_symbol(symbol)
  symbol = (symbol or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if symbol == "" then
    symbol = vim.fn.expand("<cword>")
  end
  return (symbol or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

function M.page_url(symbol, common)
  return ("%s/classes/class_%s.html"):format(common.build_base_url(), common.class_slug(symbol))
end

--- Open Godot class reference without hitting docs.godotengine.org for URL resolution.
--- godotdev resolves pages via HTML on docs.godotengine.org first; when that host
--- rate-limits or blocks requests, every lookup fails even though GitHub RST works.
function M.open(symbol)
  symbol = M.extract_symbol(symbol)
  if symbol == "" then
    notify.warn("No symbol under cursor. Godot docs need a class name (e.g. Node2D).", "kathi.godot")
    return
  end

  if not symbol:match("^[A-Z]") then
    notify.warn(
      ("`%s` is not a Godot class. Put the cursor on a PascalCase class (Node, Sprite2D) or pass `:KathiGodotDocs ClassName`. Use `K` for method/property hover via LSP."):format(
        symbol
      ),
      "kathi.godot"
    )
    return
  end

  local fetch, render, common = godotdev_docs_modules()
  if not fetch then
    notify.error("godotdev.nvim docs modules are not loaded yet.", "kathi.godot")
    return
  end

  local page_url = M.page_url(symbol, common)

  fetch.fetch_markdown(symbol, function(markdown, rst_url)
    if markdown == "" then
      vim.ui.open(page_url)
      return
    end
    render.open_float(symbol, markdown, rst_url, page_url)
  end, function()
    vim.ui.open(page_url)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("KathiGodotDocs", function(opts)
    M.open(opts.args)
  end, {
    nargs = "?",
    desc = "Open Godot class docs (RST-first, works when docs.godotengine.org is rate-limited)",
  })
end

return M
