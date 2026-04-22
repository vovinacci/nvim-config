return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      integrations = {
        treesitter = true,
        treesitter_context = true,
        which_key = true,
        mini = { enabled = true },
        flash = true,
        illuminate = { enabled = true },
        indent_blankline = { enabled = true, scope_color = "" },
        notify = true,
        noice = true,
        bufferline = true,
        ufo = true,
        dropbar = { enabled = true },
        lualine = { enabled = true },
        native_lsp = { enabled = true },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
}
