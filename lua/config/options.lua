-- OSC52 clipboard provider for SSH sessions.
-- Must run BEFORE any vim.opt.clipboard assignment: vim.g.clipboard
-- overrides the clipboard option's provider selection.
if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = osc52.paste("+"),
      ["*"] = osc52.paste("*"),
    },
  }
end

-- Disable netrw early. Neo-tree replaces it (filetree.lua wires the dir-launch
-- handoff). Must be set before plugin/runtime load to suppress the netrw
-- listing window on `nvim <dir>`.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Deprecation shim: force backtrace on every vim.deprecate() call so the
-- offending plugin + line shows up in :messages / :Noice history.
do
  local _orig = vim.deprecate
  vim.deprecate = function(name, alt, ver, plugin, _)
    return _orig(name, alt, ver, plugin, true)
  end
end

local opt = vim.opt

opt.clipboard = "unnamedplus"
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.termguicolors = true
opt.mouse = "a"
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.smartindent = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }
opt.inccommand = "split"

-- Persistent undo. Disable swap and backup (redundant with undo + git).
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- Diagnostics defaults.
vim.diagnostic.config({
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
  virtual_text = { spacing = 2, prefix = "*" },
  float = { border = "rounded", source = "if_many" },
  update_in_insert = false,
})
