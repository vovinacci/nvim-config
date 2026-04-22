# Agent Rules - nvim-config

Inherits personal global rules (`~/.config/agents/personal.md`).
Layered overrides only below.

## Stack

NeoVim >= 0.11. Lua. lazy.nvim plugin manager. mason.nvim for LSP /
DAP / formatter / linter installs. Standalone language plugins:
nvim-metals (Scala), rustaceanvim (Rust). Cross-platform: macOS and
Linux. Design doc: `docs/DESIGN.md` (added in Phase 6).

## Build & Test

Phase 1+ provides:

- `make smoke-test` - headless plugin / keymap / option checks
- `make lsp-test` - LSP attach + diagnostics
- `make startup-time` - assert startup under threshold
- `make health` - `:checkhealth config`
- `make check-lockfile` - lazy-lock.json clean
- `make lint` / `make fmt` - stylua

Until Phase 1 lands, only smoke is `nvim --headless -c "qa!"` exits 0
with zero stderr.

## Repo conventions

- Lua style: stylua, 2-space indent, double quotes, 120 cols.
- One plugin per file in `lua/plugins/` unless tight group.
- Prefer `opts` over `config` in plugin specs.
- LSP additions must list (a) Mason package name, (b) lspconfig
  name, (c) on_attach exceptions.
- Lockfile: never bump `lazy-lock.json` as side effect; only via
  `:Lazy update` (user-initiated). `lazy-lock.json` IS committed and
  IS NOT in `.gitignore`.
- Mason registry pin documented in `plugins/lsp.lua` once added.
- Big-file handler invariants: do not enable LSP / treesitter for
  buffers where `vim.b.big_file == true`.
- Per-machine config: `lua/config/local.lua` (gitignored). Tracked
  template: `lua/config/local.lua.example`. Set `vim.g.*` for
  machine-specific values (project roots, paths, secrets staging).
  Never commit hardcoded org names or absolute user paths into
  tracked Lua.
- AGENTS.md is canonical. `CLAUDE.md` and `.cursor/rules` are
  symlinks to it; do not convert to regular files.

## Quarantine list

Bump these one-per-commit so regressions bisect cleanly:

- `nvim-metals`
- `rustaceanvim`
- `blink.cmp`
- `mason.nvim`
- `mason-lspconfig.nvim`

## Done checklist

- `make test` green
- `:checkhealth config` no new red
- Startup time within budget (local 80ms, CI macOS 200ms, CI Linux
  150ms)

## Rejected Findings

(none yet)
