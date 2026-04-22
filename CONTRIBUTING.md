# Contributing to nvim-config

Phase 1 placeholder. PR workflow, test requirements, and lockfile
policy land in later phases (see `docs/DESIGN.md` Section 24).

## macOS terminal note

`<C-h>` is delivered as backspace by Apple's Terminal.app. The
`smart-splits` keymaps (`<C-h/j/k/l>`) require a terminal that
distinguishes `<C-h>` from `<BS>`:

- iTerm2
- WezTerm
- Kitty
- Alacritty

If your terminal does not, configure it to send `^[[104;5u` for
`Ctrl-h` (CSI-u protocol) and enable CSI-u handling in NeoVim.
