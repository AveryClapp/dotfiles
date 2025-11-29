# Dotfiles

Personal configuration files for development tools with unified Kanagawa Wave theme and vim-centric workflows.

## Features

- **Unified Theme** - Kanagawa Wave across all tools
- **Vim Keybindings** - Consistent shortcuts in Neovim, Taskwarrior-TUI, and Tmux
- **Task Management** - Taskwarrior with custom aliases and TUI
- **LSP Support** - 15+ languages with autocomplete and diagnostics

## Contents

- **Neovim** - Modern vim configuration based on kickstart.nvim with Kanagawa Wave theme
- **Taskwarrior** - Task management with custom Kanagawa theme and vim-style aliases
- **Taskwarrior-TUI** - Terminal UI for Taskwarrior with vim keybindings
- **Tmux** - Terminal multiplexer with custom keybindings
- **Zsh** - Shell configuration with Oh My Zsh
- **Starship** - Cross-shell prompt

## Prerequisites

- Git
- curl or wget
- A Nerd Font (JetBrains Mono will be installed automatically)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
```

2. Run the setup script:
```bash
chmod +x setup_config.sh
./setup_config.sh
```

The script will:
- Install all necessary dependencies (Neovim, tmux, zsh, ripgrep, taskwarrior, etc.)
- Install JetBrains Mono Nerd Font
- Install Oh My Zsh and Starship prompt
- Backup your existing configurations
- Copy all configuration files to their appropriate locations
- Set up Taskwarrior and Taskwarrior-TUI with custom configurations

3. Follow the post-installation steps displayed by the script

## Post-Installation

### Tmux
- Start tmux and press `Ctrl-a + I` to install plugins via TPM

### Neovim
- Open Neovim (`nvim`) and wait for lazy.nvim to install all plugins automatically
- Run `:Mason` to check LSP server installation status

### Zsh
- If not already done, change your default shell:
  ```bash
  chsh -s $(which zsh)
  ```
- Log out and back in for the change to take effect

## Configuration Details

### Neovim
- Based on kickstart.nvim with Kanagawa Wave theme
- LSP support: Go, Rust, Python, TypeScript, C/C++, Java, and more
- Custom keybindings: `J/K` (10-line jumps), `H/L` (line start/end), Space (leader)
- Telescope (fuzzy finding, git-aware), Harpoon (file navigation)
- Git integration (gitsigns, fugitive), lualine, alpha-nvim

### Taskwarrior
- Kanagawa color theme matching Neovim
- Vim-style aliases: `task a` (add), `task d` (done), `task m` (modify), `task s` (start), `task e` (edit)
- Pre-configured contexts: `work`, `personal`
- Custom task estimates: 5m, 15m, 30m, 1h, 2h, 4h, 1d
- See [docs/taskwarrior-guide.md](docs/taskwarrior-guide.md) for complete documentation

### Taskwarrior-TUI
- Vim keybindings: `j/k` (navigate), `J/K` (page scroll), `gg/G` (top/bottom), `H/L` (tabs)
- Search: `/` (search), `:` (command mode)
- Task operations: `a/d/s/m/e/x/u`
- See [docs/taskwarrior-guide.md](docs/taskwarrior-guide.md) for complete reference

### Tmux
- Prefix changed to `Ctrl-a`
- Vim-style pane navigation
- Themed status bar with system monitoring
- Window navigation with Alt+Left/Right
- Copy mode with vi keybindings

### Zsh
- Oh My Zsh with useful plugins (git, aws, docker, python, tmux)
- Starship prompt with minimal theme
- Custom aliases (vim → nvim)

## Documentation

- [Taskwarrior Guide](docs/taskwarrior-guide.md) - Complete task management guide with keybindings and workflows

## Customization

Key files:
- `~/.config/nvim/init.lua` - Neovim
- `~/.config/nvim/lua/custom/plugins/colorscheme.lua` - Kanagawa theme
- `~/.taskrc` - Taskwarrior
- `~/.config/taskwarrior-tui/config.toml` - Taskwarrior-TUI
- `~/.tmux.conf` - Tmux
- `~/.zshrc` - Zsh
- `~/.config/starship.toml` - Starship

Apply changes: Run `./setup_config.sh` or manually copy modified files to `~/`

## Troubleshooting

**Fonts not displaying**: Configure terminal to use JetBrains Mono Nerd Font. On Linux, run `fc-cache -fv`.

**Tmux plugins**: Press `Ctrl-a + I` inside tmux to install.

**Neovim plugins**: Check `:Lazy` status or run `:Lazy sync`.

**Taskwarrior colors**: Ensure terminal supports 256 colors and `$TERM` is set (e.g., `xterm-256color`).

**Taskwarrior-TUI keybindings**: Verify config with `cat ~/.config/taskwarrior-tui/config.toml`.

## Supported Platforms

- macOS (with Homebrew)
- Linux (Debian/Ubuntu, Fedora, Arch)

## License

MIT License - See nvim/LICENSE.md for details
