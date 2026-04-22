return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      {
        "<leader>e",
        function()
          -- "reveal" on an unnamed/unreadable buffer can spawn a phantom
          -- [No Name] entry; only request reveal when current buf is a real
          -- file on disk.
          local name = vim.api.nvim_buf_get_name(0)
          if name ~= "" and vim.fn.filereadable(name) == 1 then
            vim.cmd("Neotree toggle reveal")
          else
            vim.cmd("Neotree toggle")
          end
        end,
        desc = "Explorer",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      sources = { "filesystem", "git_status", "buffers" },
      -- Do NOT auto-close neo-tree when it becomes the last window;
      -- doing so cascades on <leader>bd (bdelete -> only tree left ->
      -- tree closes -> zero windows -> nvim exits).
      close_if_last_window = false,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_default",
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { ".DS_Store", "node_modules", "target", ".terraform" },
        },
      },
      window = {
        width = 35,
        mappings = {
          ["<space>"] = "none",
          ["o"] = "open",
        },
      },
      default_component_configs = {
        indent = { with_markers = true },
        git_status = {
          symbols = {
            added = "+", modified = "~", deleted = "-",
            renamed = ">", untracked = "?", ignored = "!",
            unstaged = "*", staged = "@", conflict = "X",
          },
        },
      },
    },
  },
}
