return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "catppuccin-mocha",
        globalstatus = true,
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      {
        "<leader>bd",
        function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype == "neo-tree" then
            vim.notify("Cannot delete from neo-tree window", vim.log.levels.WARN)
            return
          end
          if vim.bo[buf].modified then
            vim.notify("Buffer modified; :w to save or :bd! to discard", vim.log.levels.WARN)
            return
          end
          local listed = vim.tbl_filter(function(b)
            return vim.bo[b].buflisted and b ~= buf
          end, vim.api.nvim_list_bufs())
          if #listed > 0 then
            vim.cmd("bprevious")
          else
            vim.cmd("enew")
          end
          pcall(vim.api.nvim_buf_delete, buf, { force = false })
        end,
        desc = "Delete buffer (keep split)",
      },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close others" },
      { "<leader>bp", "<cmd>BufferLineCyclePrev<CR>",   desc = "Prev buffer" },
      { "<leader>bn", "<cmd>BufferLineCycleNext<CR>",   desc = "Next buffer" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        offsets = {
          { filetype = "neo-tree", text = "Explorer", separator = true },
        },
      },
    },
  },

  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  {
    "kevinhwang91/nvim-ufo",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "kevinhwang91/promise-async" },
    init = function()
      vim.opt.foldcolumn = "1"
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldenable = true
    end,
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
    },
  },
}
