# nvim-config

Personal Neovim configuration. From-scratch on
[lazy.nvim](https://github.com/folke/lazy.nvim). IntelliJ refugee
defaults: aggressive lazy-loading, opinionated keymaps, OSC52 clipboard
for SSH, no surprises.

## Status

Phase 2 -- core editor + navigation/fuzzy/terminal. No LSP yet.

Shipped:

- Catppuccin (mocha)
- nvim-treesitter (`main` branch) with textobjects + context
- which-key, mini.pairs, mini.surround, Comment, indent-blankline,
  flash, todo-comments, illuminate, dressing, yanky
- lualine, bufferline, devicons, dropbar, nvim-ufo
- smart-splits (tmux-aware window nav)
- neo-tree (filetree, dir-launch hijack)
- fzf-lua (files, grep, buffers, projects, diagnostics)
- toggleterm (float / horizontal / vertical)
- Big-file handler (>1MB disables treesitter / LSP / indent-guides)

## Install

```sh
git clone https://github.com/vovinacci/nvim-config.git ~/src/vovinacci/nvim-config
ln -s ~/src/vovinacci/nvim-config ~/.config/nvim
nvim
```

First launch bootstraps lazy.nvim and installs all plugins.

### System dependencies

| Tool          | Used by                       |
|---------------|-------------------------------|
| `tree-sitter` | nvim-treesitter parser builds |
| `fzf`         | fzf-lua                       |
| `ripgrep`     | fzf-lua live grep             |
| `fd`          | fzf-lua file scan, projects   |

macOS: `brew install tree-sitter-cli fzf ripgrep fd`

## Per-machine config

`lua/config/local.lua` is gitignored. Copy from
`lua/config/local.lua.example` and set machine-specific values
(currently: `vim.g.project_roots` for `<leader>fp`).

## Keymaps

`<space>` is leader. `<leader>` then wait -- which-key shows the menu.

Highlights:

| Key            | Action                              |
|----------------|-------------------------------------|
| `<leader>e`    | Toggle neo-tree (reveal real files) |
| `<leader>ff`   | Find files (fzf-lua)                |
| `<leader>fg`   | Live grep                           |
| `<leader>fb`   | Buffers                             |
| `<leader>fp`   | Project picker                      |
| `<leader>bd`   | Delete buffer (keeps split)         |
| `<leader>bp`/`bn` | Prev / next buffer               |
| `<S-h>`/`<S-l>` | Prev / next buffer (no leader)     |
| `<C-\>`        | Toggle floating terminal            |
| `<C-h/j/k/l>`  | Move between splits + tmux panes    |
| `gz`-prefix    | mini.surround (add/change/delete)   |
| `s`            | flash.nvim jump                     |

## Debugging

`:DebugInfo` -- dumps Neovim version, runtime paths, lazy plugin
inventory, treesitter parser status, clipboard provider, terminal env.
First port of call when something looks off.

## Contributing

See `CONTRIBUTING.md`. Personal config; PRs welcome but no guarantee
they land.

## License

MIT. See `LICENSE`.
