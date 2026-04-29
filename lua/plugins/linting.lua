-- nvim-lint -- async linting, complements LSP diagnostics. Triggered on
-- BufReadPost / BufWritePost / InsertLeave. Skip big files (vim.b.big_file).
--
-- Linters live in :MasonInstall (or brew). Missing-linter behaviour:
-- nvim-lint logs once via vim.notify and skips that filetype silently.
return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    keys = {
      {
        "<leader>ll",
        function() require("lint").try_lint() end,
        desc = "Lint buffer",
      },
    },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        yaml = { "yamllint" },
        dockerfile = { "hadolint" },
        go = { "golangcilint" },
        terraform = { "tflint" },
      }
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("UserLint", { clear = true }),
        callback = function(args)
          if vim.b[args.buf].big_file then return end
          pcall(lint.try_lint)
        end,
      })
    end,
  },
}
