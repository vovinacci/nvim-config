-- blink.cmp -- Rust-based fuzzy completion. Sources: LSP, path, snippets,
-- buffer. Snippet engine: LuaSnip (per design doc punch-list #13). Capabilities
-- propagate to vim.lsp.config() via lsp.lua's pcall(require("blink.cmp")...).
--
-- Build: blink.cmp ships prebuilt binaries; if absent, falls back to
-- `cargo build --release` (Rust toolchain present, see :checkhealth blink).
return {
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    version = "v2.*",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
  },
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "v1.*",
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = true },
        menu = { border = "rounded" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      snippets = { preset = "luasnip" },
      signature = { enabled = true, window = { border = "rounded" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
