-- conform.nvim -- format on save with minimal diffs. LSP-side formatting
-- already disabled in lsp.lua on_attach (punch-list #5), so conform is the
-- single formatter source.
--
-- Big-file invariant: format_on_save returns nil for vim.b.big_file buffers
-- so the BufWritePre hook short-circuits before invoking any formatter.
--
-- Per-language formatters live in :MasonInstall (or brew) -- conform does
-- not bundle binaries. Missing-formatter behaviour: conform notifies once
-- per session, no stack trace.
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format({ async = true, lsp_format = "never" })
        end,
        mode = { "n", "v" },
        desc = "Format buffer/range",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "goimports", "gofumpt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        yaml = { "prettier" },
        json = { "prettier" },
        markdown = { "prettier" },
        terraform = { "terraform_fmt" },
      },
      format_on_save = function(bufnr)
        if vim.b[bufnr].big_file then return end
        if not vim.bo[bufnr].modifiable then return end
        return { timeout_ms = 500, lsp_format = "never" }
      end,
      formatters = {
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
      },
    },
  },
}
