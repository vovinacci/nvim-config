local hl = vim.hl or vim.highlight

-- Highlight yanked region briefly.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    hl.on_yank({ timeout = 200 })
  end,
})

-- Big-file handler: disable expensive features for files > 1MB.
-- See docs/DESIGN.md Section 19. LSP detach uses vim.lsp.stop_client
-- (punch-list #4); vim.lsp.buf_detach_client was removed.
local big_file_group = vim.api.nvim_create_augroup("BigFile", { clear = true })
vim.api.nvim_create_autocmd("BufReadPre", {
  group = big_file_group,
  callback = function(args)
    local max_size = 1024 * 1024
    local fname = vim.api.nvim_buf_get_name(args.buf)
    local ok, stats = pcall(vim.uv.fs_stat, fname)
    if ok and stats and stats.size > max_size then
      vim.b[args.buf].big_file = true
      pcall(vim.treesitter.stop, args.buf)
      vim.api.nvim_create_autocmd("LspAttach", {
        buffer = args.buf,
        callback = function(a)
          vim.lsp.stop_client(a.data.client_id, true)
        end,
      })
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
      vim.schedule(function()
        pcall(vim.cmd, "IBLDisable")
        pcall(vim.cmd, "IlluminatePauseBuf")
      end)
      vim.notify(
        "Big file detected -- treesitter, LSP, indent guides disabled",
        vim.log.levels.INFO
      )
    end
  end,
})

-- Auto-quit when only auxiliary windows remain (neo-tree, qf, help, plus
-- empty unmodified [No Name] scratch). Lets a single :q on the editing
-- window exit nvim cleanly when the rest of the tab is just the explorer.
-- Modified buffers still prompt because :qa honors them. See punch-list
-- #42 for AUX-extension policy.
local AUX_FT = {
  ["neo-tree"] = true,
  ["neo-tree-popup"] = true,
  qf = true,
  help = true,
  Outline = true,        -- punch-list #42: outline.nvim sidebar (Phase 3a)
}
local function is_aux_buf(buf)
  if AUX_FT[vim.bo[buf].filetype] then return true end
  -- Empty [No Name] scratch in a normal (non-special) buffer slot is
  -- transient; treat as aux so post-bdelete enew + neo-tree triggers exit.
  if vim.bo[buf].buftype == ""
    and not vim.bo[buf].modified
    and vim.api.nvim_buf_get_name(buf) == "" then
    return true
  end
  return false
end
-- Trigger on explicit close commands only:
--   QuitPre   -- :q, :q!, :qa, :wq, :x, :ZZ (user intent to close window/nvim)
--   BufDelete -- :bd, :bw, nvim_buf_delete (our <leader>bd)
-- WinClosed is intentionally NOT used: plugin internals (neo-tree open,
-- fzf-lua dismiss) fire it and would cause spurious exits.
local auto_quit_in_progress = false
local function should_auto_quit(skip_win)
  -- Modified buffers (visible or hidden) abort the check; user must :wa or :qa!.
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].modified then return false end
  end
  local has_real_window = false
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= skip_win then
      -- Any float means user is mid-popup (fzf-lua picker, lsp hover); skip.
      if vim.api.nvim_win_get_config(win).relative ~= "" then return false end
      has_real_window = true
      if not is_aux_buf(vim.api.nvim_win_get_buf(win)) then return false end
    end
  end
  return has_real_window
end
local aux_group = vim.api.nvim_create_augroup("AutoQuitOnAuxOnly", { clear = true })
-- Dir-launch session: `nvim <dir>` should land in neo-tree, not exit on bd.
-- Set in VimEnter below; consumed by BufDelete handler.
local launched_with_dir = false
vim.api.nvim_create_autocmd("VimEnter", {
  group = aux_group,
  callback = function()
    if #vim.api.nvim_list_uis() == 0 then return end
    local args = vim.fn.argv()
    if #args ~= 1 then return end
    if vim.fn.isdirectory(args[1]) ~= 1 then return end
    launched_with_dir = true
    local dir = vim.fn.fnamemodify(args[1], ":p"):gsub("/$", "")
    -- The buf nvim opened for argv[1] is current at VimEnter and -- given the
    -- #argv==1 + isdirectory gate -- is guaranteed to be the dir/netrw buf.
    local dir_buf = vim.api.nvim_get_current_buf()
    pcall(vim.cmd, "cd " .. vim.fn.fnameescape(dir))
    vim.schedule(function()
      -- Wipe the dir buf first. nvim auto-fills its window with a fresh
      -- [No Name], avoiding the split/enew race that produced phantom
      -- main-area windows when ordered the other way.
      if vim.api.nvim_buf_is_valid(dir_buf) then
        pcall(vim.api.nvim_buf_delete, dir_buf, { force = true })
      end
      pcall(vim.cmd, "Neotree show position=left")
    end)
  end,
})
-- QuitPre fires BEFORE the window closes. Predict post-close state by
-- excluding the current window from the check; act synchronously to avoid
-- the [No Name] / aux-only flash between :q and the auto-quit.
vim.api.nvim_create_autocmd("QuitPre", {
  group = aux_group,
  callback = function()
    if vim.v.vim_did_enter == 0 then return end
    if vim.g.SessionLoad == 1 then return end
    if auto_quit_in_progress then return end
    if not should_auto_quit(vim.api.nvim_get_current_win()) then return end
    auto_quit_in_progress = true
    pcall(vim.cmd, "silent! qa")
  end,
})
-- BufDelete fires AFTER the buffer is gone. Schedule the check so window
-- state (e.g. enew fallback in <leader>bd) is settled before we look.
-- Only react to deletion of real file buffers; directories (neo-tree
-- netrw hijack at startup), help, qf, terminal, fzf-lua, etc. would
-- otherwise trigger spurious exits.
vim.api.nvim_create_autocmd("BufDelete", {
  group = aux_group,
  callback = function(args)
    if vim.v.vim_did_enter == 0 then return end
    if vim.g.SessionLoad == 1 then return end
    if launched_with_dir then return end
    if vim.bo[args.buf].buftype ~= "" then return end
    local name = vim.api.nvim_buf_get_name(args.buf)
    if name == "" then return end
    if vim.fn.isdirectory(name) == 1 then return end
    vim.schedule(function()
      if auto_quit_in_progress then return end
      if not should_auto_quit(nil) then return end
      auto_quit_in_progress = true
      pcall(vim.cmd, "silent! qa")
    end)
  end,
})
