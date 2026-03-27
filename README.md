# Dotfiles

Personal development environment with a unified Kanagawa Wave theme. Built for C++, Rust, and Python on macOS.

## Stack

| Tool | Purpose |
|------|---------|
| **Neovim** | Primary editor — lazy.nvim, LSP, DAP, treesitter |
| **Tmux** | Terminal multiplexer with Kanagawa status bar |
| **Bash** | Shell with history substring search, eza, git-delta |
| **Alacritty** | GPU-accelerated terminal |

## Installation

```bash
git clone https://github.com/AveryClapp/dotfiles.git
cd dotfiles
chmod +x setup_config.sh
./setup_config.sh
```

The script installs dependencies (Homebrew, Neovim, tmux, eza, git-delta, Rust, ripgrep, fzf, zoxide, JetBrains Mono Nerd Font), backs up existing configs, and symlinks everything into place.

## Post-Installation

**Tmux** — press `Ctrl-a + I` inside tmux to install plugins via TPM.

**Neovim** — open `nvim`, lazy.nvim installs all plugins automatically. Then run `:Mason` to verify LSP servers.

**Shell** — `source ~/.bashrc` or open a new terminal.

## Key Files

```
bashrc                          # bash config (aliases, history, completions)
tmux.conf                       # tmux config
alacritty.toml                  # terminal config
nvim/                           # neovim config
  init.lua                      # options, keymaps, lazy bootstrap
  lua/custom/plugins/           # one file per plugin
GUIDE.md                        # complete nvim keybind reference
setup_config.sh                 # automated install script
```

## Neovim Highlights

- **Languages**: C++ (clangd + DAP + CMake), Rust (rustaceanvim + clippy), Python (pyright + ruff)
- **Navigation**: Flash, Harpoon, Telescope, Oil, Aerial
- **Git**: Neogit + Diffview (full Magit-style workflow inside nvim)
- **Editing**: nvim-surround, mini.ai, targets.vim, nvim-spider (subword motions), nvim-recorder (named macro slots)
- **UI**: Kanagawa Wave, lualine, alpha-nvim dashboard, nvim-notify, indent-blankline, treesitter-context
- **Sessions**: persistence.nvim — auto-saves and restores per-directory sessions
- **Terminal**: toggleterm (`<leader>T`), project-local keymaps via `.nvim.lua`

See [GUIDE.md](GUIDE.md) for the full keybind reference.

## Tmux Keybinds

Prefix: `Ctrl-a`

| Key | Action |
|-----|--------|
| `prefix + arrows` | Switch panes (repeatable) |
| `prefix + hjkl` | Resize panes |
| `prefix + \|` | Split vertical |
| `prefix + -` | Split horizontal |
| `Alt + Left/Right` | Switch windows |

## Troubleshooting

**Fonts not rendering** — set terminal font to JetBrains Mono Nerd Font.

**Tmux plugins missing** — press `Ctrl-a + I` inside tmux.

**Nvim plugins missing** — run `:Lazy sync`.

**Colors wrong in tmux** — ensure `$TERM` reports `xterm-256color` from your terminal emulator. The config sets `tmux-256color` + true color passthrough internally.
