return {
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    keys = {
      { [[<C-\>]], desc = "Toggle terminal" },
      { "<leader>Tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Float term" },
      { "<leader>Th", "<cmd>ToggleTerm direction=horizontal size=15<CR>", desc = "Horizontal term" },
      { "<leader>Tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Vertical term" },
    },
    opts = {
      open_mapping = [[<C-\>]],
      shell = vim.o.shell,
      direction = "float",
      persist_mode = true,
      size = function(term)
        if term.direction == "horizontal" then return 15 end
        if term.direction == "vertical" then return math.floor(vim.o.columns * 0.4) end
        return 0
      end,
      float_opts = { border = "rounded" },
      on_open = function(term)
        local opts = { buffer = term.bufnr, silent = true }
        vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], opts)
      end,
    },
  },
}
