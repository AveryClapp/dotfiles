# Dotfiles

Personal development environment with a unified Kanagawa Wave theme. Built for C++, Rust, and Python on macOS.

## Stack

| Tool | Purpose |
|------|---------|
| **Neovim** | Primary editor — lazy.nvim, 43 plugins, LSP, DAP, treesitter |
| **Tmux** | Terminal multiplexer with Kanagawa status bar |
| **Bash** | Shell with smart navigation, history search, eza, bat, git-delta |
| **Alacritty** | GPU-accelerated terminal |
| **Ghostty** | Agent-workstation terminal with shell integration and notifications |
| **Beads + workmux** | Agent task graph, isolated worktrees, and tmux lifecycle |
| **mise + just** | Pinned project tools and one human/agent verification contract |
| **CASS + ast-grep** | Cross-agent history search and structural code search |

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

For SSH or remote machines where you only want terminal tools and config:
```bash
./setup_config.sh --ssh
./setup_config.sh --ssh --no-sudo
```

For the additive agentic engineering environment:

```bash
./setup_config.sh --profile agent              # CLI/SSH host
./setup_config.sh --profile agent-workstation  # full setup + Ghostty
./setup_config.sh --profile agent-workstation --skill-pack all
```

These profiles share the existing shell, tmux, Git, and Neovim config. They do
not remove Alacritty or the manual worktree/sessionizer workflow. See
[docs/agentic-engineering.md](docs/agentic-engineering.md) for the architecture,
commands, and operating protocol.

Agent profiles install the portable `general` skill pack by default. Add
`--skill-pack web`, `security`, or `research` as needed; the option is
repeatable, and `all` selects every pack. `--skill-pack none` keeps only the
personal skills cloned from `github.com/AveryClapp/agent-skills` into the sibling
`../agent-skills` repository. The web pack downloads agent-browser and its
Chromium runtime. Use `--skip-personal-skills` to omit the personal repo or
`--skip-claude-plugins` to omit Claude-specific LSP and review plugins.

Preview either profile without changing the machine:

```bash
./setup_config.sh --ssh --no-sudo --dry-run
```

The script installs dependencies based on the selected profile, backs up existing configs, and copies everything into place. The default profile is a full local workstation setup; `--ssh` skips GUI-only pieces like Alacritty, fonts, and Emacs/Doom.

## Post-Installation

**Tmux** — press `Ctrl-a + I` inside tmux to install plugins via TPM (includes tmux-resurrect).

**Neovim** — open `nvim`, lazy.nvim installs all plugins automatically. Then run `:Mason` to verify LSP servers.

**Shell** — `source ~/.bashrc` or open a new terminal.

**Agent profile** — run `agent-doctor` and `just check`. Both should complete
without warnings before the first agent task.

## Syncing Existing Machines

Apply the current checkout without installing packages or pulling from Git:

```bash
make sync
make sync ARGS="--ssh"          # terminal-only machine
make agent-sync                 # terminal-only agent config
make sync ARGS="--profile agent-workstation"
make sync ARGS="--dry-run"      # preview destinations
exec bash
```

Personal skills are authored in the separate sibling `../agent-skills` Git repository.
Agent sync links them into the shared `~/.agents/skills` catalog, then publishes
the catalog to Claude and Codex. Third-party skill packs remain upstream-managed,
and existing non-symlink client-specific skills are preserved.

`make update` is intentionally broader: it pulls the repository, syncs config,
then updates Neovim and Doom packages. Run `dotfiles-doctor` (or `make doctor`)
to find config drift, nested repositories, broken Git completion, credential
helper hardcoding, missing tools, and Intel binaries on Apple Silicon.

Machine-specific paths and SSH helpers live in
`~/.config/dotfiles/local.bash`. It is initialized from `local.bash.example`,
sourced last, and never overwritten. Machine-specific Git settings use the
similarly preserved `~/.gitconfig.local`.

## Key Files

```
bashrc                          # bash config (history, completions, functions)
aliases                         # all shell aliases (sourced from bashrc)
gitconfig                       # git quality-of-life settings
tmux.conf                       # tmux config
alacritty.toml                  # terminal config
bin/tmux-sessionizer            # project session switcher (prefix+f)
bin/tmux-worktree               # git worktree + session switcher (prefix+w)
bin/dotfiles-doctor             # shell, Git, architecture, and config checks
bin/agent-*                     # initialize, launch, inspect, review, and land agents
agent/                          # workmux defaults and global agent guidance
ghostty/                        # optional agent-workstation terminal config
.mise.toml                      # pinned repository development tools
justfile                        # canonical check, lint, security, and sync tasks
lefthook.yml                    # staged-secret pre-commit check; no pre-push hook
.gitleaks.toml                  # default rules plus Authorization-header detection
local.bash.example              # optional machine-local overrides
nvim/                           # neovim config
  init.lua                      # options, keymaps, lazy bootstrap
  lua/custom/plugins/           # one file per plugin (43 total)
GUIDE.md                        # complete keybind and plugin reference
setup_config.sh                 # automated install script
```

## Shell

- **eza** — `ls`, `ll`, `lt`, `la` with color and icons
- **bat** — `cat` replacement with syntax highlighting
- **zoxide** — `z <query>` or `j <query>` to jump to any recently visited directory
- **fzf** — `Ctrl+R` fuzzy history, `fv` fuzzy open in nvim, `fcd` fuzzy cd, `flog` fuzzy git log
- **git-delta** — syntax-highlighted diffs for all git commands
- **pure-bash prompt** — fish-style paths, git branch via `.git/HEAD` read, zero subprocess cost
- **smart cd** — `cd ...`, `cd ....`, `up 3`, `mkcd dir`, and `croot`
- **direnv** — auto-loads `.envrc` on `cd`, unloads on `cd` away
- **ssh-agent** — persistent agent shared across all terminals via `~/.ssh/agent.env`
- **entr** — run any command when files change (`git ls-files | entr -c make`)
- **btop** — system monitor (`top` alias)
- **hyperfine** — statistical benchmarking (`bench` alias)
- **mise + just** — project-local tools and discoverable task contracts
- **ast-grep** — syntax-aware search and mechanical rewrites
- **CASS** — local search across Claude, Codex, and other agent histories
- **gitleaks + Lefthook** — Git-aware working-tree checks and fast staged-secret scanning before commits
- **tldr** — practical man pages with real examples (`help` alias)

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
| `prefix + w` | Worktree — pick branch, create worktree + session |
| `prefix + W` | Agent worktree — claim/select a task and launch workmux |
| `prefix + g` | Agent dashboard |
| `prefix + G` | Jump to latest completed/waiting agent |
| `prefix + Tab` | Toggle between recent agents |
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

**Shell is wrong** — run `echo $0` (not `$SHELL`) to check the actual running shell. Alacritty and tmux inherit your login shell; change it with `chsh -s "$(command -v bash)"`.
