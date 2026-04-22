local parsers = {
  "bash",
  "c",
  "cpp",
  "dockerfile",
  "go",
  "hcl",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "proto",
  "python",
  "rust",
  "scala",
  "toml",
  "typescript",
  "vimdoc",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
      require("nvim-treesitter").install(parsers, { summary = true }):wait(300000)
    end,
    config = function()
      -- Idempotent: installs missing parsers async on subsequent sessions.
      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nvim_treesitter_start", { clear = true }),
        callback = function(ev)
          local buf = ev.buf
          if vim.b[buf].big_file then
            return
          end
          if vim.api.nvim_buf_line_count(buf) > 50000 then
            return
          end
          if pcall(vim.treesitter.start, buf) then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local function pick(query)
        return function()
          select.select_textobject(query, "textobjects")
        end
      end
      local map = vim.keymap.set
      map({ "x", "o" }, "af", pick("@function.outer"), { desc = "Outer function" })
      map({ "x", "o" }, "if", pick("@function.inner"), { desc = "Inner function" })
      map({ "x", "o" }, "ac", pick("@class.outer"), { desc = "Outer class" })
      map({ "x", "o" }, "ic", pick("@class.inner"), { desc = "Inner class" })
      map({ "x", "o" }, "aa", pick("@parameter.outer"), { desc = "Outer parameter" })
      map({ "x", "o" }, "ia", pick("@parameter.inner"), { desc = "Inner parameter" })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = { max_lines = 3, mode = "cursor" },
  },
}
