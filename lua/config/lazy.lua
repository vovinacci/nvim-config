-- Bootstrap lazy.nvim. Empty plugin spec for now; plugin specs land
-- in lua/plugins/ in later phases (see docs/DESIGN.md Section 24).
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local ok, lazy = pcall(require, "lazy")
if not ok then
  vim.notify("lazy.nvim not installed. Run: make install", vim.log.levels.WARN)
  return
end

lazy.setup({
  spec = { { import = "plugins" } },
  install = { missing = true },
  checker = { enabled = false },
  change_detection = { notify = false },
})
