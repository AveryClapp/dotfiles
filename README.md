# Dotfiles

Personal development environment with a unified Kanagawa Wave theme. Built for C++, Rust, and Python on macOS.

## Stack

| Tool | Purpose |
|------|---------|
| **Neovim** | Primary editor — lazy.nvim, 43 plugins, LSP, DAP, treesitter |
| **Tmux** | Terminal multiplexer with Kanagawa status bar |
| **Bash** | Shell with oh-my-bash, history search, eza, bat, git-delta |
| **Alacritty** | GPU-accelerated terminal |

## Installation

```bash
git clone https://github.com/AveryClapp/dotfiles.git
cd dotfiles
chmod +x setup_config.sh
./setup_config.sh
```

Or with make:
```bash
make install
```

The script installs all dependencies (Homebrew, Neovim, tmux, eza, bat, git-delta, Rust, ripgrep, fzf, zoxide, direnv, oh-my-bash, JetBrains Mono Nerd Font), backs up existing configs, and copies everything into place.

## Post-Installation

**Tmux** — press `Ctrl-a + I` inside tmux to install plugins via TPM (includes tmux-resurrect).

**Neovim** — open `nvim`, lazy.nvim installs all plugins automatically. Then run `:Mason` to verify LSP servers.

**Shell** — `source ~/.bashrc` or open a new terminal.

## Key Files

```
bashrc                          # bash config (history, completions, functions)
aliases                         # all shell aliases (sourced from bashrc)
gitconfig                       # git quality-of-life settings
tmux.conf                       # tmux config
alacritty.toml                  # terminal config
bin/tmux-sessionizer            # project session switcher (prefix+f)
nvim/                           # neovim config
  init.lua                      # options, keymaps, lazy bootstrap
  lua/custom/plugins/           # one file per plugin (43 total)
GUIDE.md                        # complete keybind and plugin reference
setup_config.sh                 # automated install script
```

## Shell

- **eza** — `ls`, `ll`, `lt`, `la` with color and icons
- **bat** — `cat` replacement with syntax highlighting
- **zoxide** — `z <query>` to jump to any recently visited directory
- **fzf** — `Ctrl+R` fuzzy history, `fv` fuzzy open in nvim, `fcd` fuzzy cd, `flog` fuzzy git log
- **git-delta** — syntax-highlighted diffs for all git commands
- **oh-my-bash** — sudo (double `Esc`), bashmarks (`s`/`g`), colored man pages
- **pure-bash prompt** — fish-style paths, git branch via `.git/HEAD` read, zero subprocess cost
- **direnv** — auto-loads `.envrc` on `cd`, unloads on `cd` away
- **ssh-agent** — persistent agent shared across all terminals via `~/.ssh/agent.env`

## Neovim

- **Languages**: C++ (clangd + DAP + CMake), Rust (rustaceanvim + clippy), Python (pyright + ruff)
- **Navigation**: Flash, Harpoon, Telescope, Oil, Aerial
- **Git**: Neogit + Diffview (full Magit-style workflow inside nvim)
- **Editing**: nvim-surround, mini.ai, targets.vim, nvim-spider, nvim-recorder, treesj, SSR, inc-rename
- **UI**: Kanagawa Wave, lualine, alpha-nvim dashboard, nvim-notify, indent-blankline, treesitter-context
- **Sessions**: persistence.nvim — auto-saves and restores per-directory sessions
- **Terminal**: toggleterm (`<leader>T`), project-local keymaps via `.nvim.lua`

See [GUIDE.md](GUIDE.md) for the full keybind reference.

## Tmux

Prefix: `Ctrl-a`

| Key | Action |
|-----|--------|
| `prefix + f` | Sessionizer — fuzzy-find project, create/switch session |
| `prefix + arrows` | Switch panes (repeatable) |
| `prefix + hjkl` | Resize panes (enter resize mode, spam freely, Esc to exit) |
| `Alt + Left/Right` | Switch windows |
| `prefix + Ctrl+s` | Save tmux session (resurrect) |
| `prefix + Ctrl+r` | Restore tmux session (resurrect) |

## Troubleshooting

**Fonts not rendering** — set terminal font to JetBrains Mono Nerd Font.

**Tmux plugins missing** — press `Ctrl-a + I` inside tmux.

**Nvim plugins missing** — run `:Lazy sync`.

**Python version showing in `~`** — check `pyenv version`. If a global is set: `pyenv global system` or `rm ~/.python-version`.

**Colors wrong in tmux** — ensure `$TERM` reports `xterm-256color` from your terminal. The config sets `tmux-256color` + true color passthrough internally.

**Shell is wrong** — run `echo $0` (not `$SHELL`) to check the actual running shell. If Alacritty opens the wrong shell, `alacritty.toml` has `terminal.shell` explicitly set to `/opt/homebrew/bin/bash`.
