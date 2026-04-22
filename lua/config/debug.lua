-- :DebugInfo opens a scratch buffer with current state of the
-- environment: nvim version, stdpaths, lazy plugin count, treesitter
-- parser inventory, clipboard provider, SSH/TERM env. Useful for bug
-- reports and "what is my nvim doing" snapshots.

local function collect()
  local lines = {}
  local function add(s)
    table.insert(lines, s)
  end

  add("# DebugInfo " .. os.date("%Y-%m-%d %H:%M:%S"))
  add("")

  add("## NeoVim")
  for _, line in ipairs(vim.split(vim.fn.execute("version"), "\n")) do
    if line ~= "" then
      add(line)
    end
  end
  add("")

  add("## stdpath")
  for _, k in ipairs({ "config", "data", "state", "log", "cache" }) do
    add(("%-8s = %s"):format(k, vim.fn.stdpath(k)))
  end
  add("")

  add("## Lazy")
  local ok_lazy, lazy = pcall(require, "lazy")
  if ok_lazy then
    local plugins = lazy.plugins()
    add("plugin_count = " .. #plugins)
    local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
    if vim.fn.filereadable(lockfile) == 1 then
      add("lockfile     = " .. lockfile)
    end
  else
    add("lazy.nvim not loaded")
  end
  add("")

  add("## Treesitter")
  add("tree-sitter CLI on PATH = " .. (vim.fn.executable("tree-sitter") == 1 and "yes" or "no"))
  local parser_dir = vim.fn.stdpath("data") .. "/site/parser"
  local parsers = vim.fn.glob(parser_dir .. "/*.so", false, true)
  add("parser_dir              = " .. parser_dir)
  add("parser_count            = " .. #parsers)
  for _, p in ipairs(parsers) do
    add("  - " .. vim.fn.fnamemodify(p, ":t:r"))
  end
  add("")

  add("## Clipboard / SSH")
  local cb = vim.opt.clipboard:get()
  add("clipboard option   = " .. (cb[1] or "(unset)"))
  add("clipboard provider = " .. (vim.g.clipboard and vim.g.clipboard.name or "(default)"))
  for _, k in ipairs({ "SSH_TTY", "SSH_CONNECTION", "TERM", "TERM_PROGRAM", "COLORTERM" }) do
    add(("%-15s = %s"):format(k, vim.env[k] or "(unset)"))
  end
  add("")

  add("## OS")
  local uname = vim.uv.os_uname()
  add(("%s %s %s"):format(uname.sysname, uname.release, uname.machine))

  return lines
end

vim.api.nvim_create_user_command("DebugInfo", function()
  local lines = collect()
  vim.cmd("vnew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "markdown"
  pcall(vim.api.nvim_buf_set_name, 0, "DebugInfo")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.modifiable = false
end, { desc = "Open scratch buffer with debug info" })
