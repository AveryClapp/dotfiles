# Dotfiles

This repository contains my personal configuration files for various development tools.

## Contents

- **Neovim** - Modern vim configuration based on kickstart.nvim
- **Tmux** - Terminal multiplexer with custom keybindings and Tokyo Night theme
- **Zsh** - Shell configuration with Oh My Zsh
- **Starship** - Cross-shell prompt with Tokyo Night colors

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
- Install all necessary dependencies (Neovim, tmux, zsh, ripgrep, etc.)
- Install JetBrains Mono Nerd Font
- Install Oh My Zsh and Starship prompt
- Backup your existing configurations
- Copy all configuration files to their appropriate locations

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
- Based on kickstart.nvim with additional customizations
- Includes LSP support for multiple languages
- Custom keybindings (J/K for 10j/10k navigation, H/L for line start/end)
- Tokyo Night color scheme
- Harpoon for quick file navigation
- Git integration with fugitive and gitsigns

### Tmux
- Prefix changed to `Ctrl-a`
- Vim-style pane navigation
- Tokyo Night themed status bar with CPU/Memory monitoring
- Window navigation with Alt+Left/Right
- Copy mode with vi keybindings

### Zsh
- Oh My Zsh with useful plugins (git, aws, docker, python, tmux)
- Starship prompt with minimal Tokyo Night theme
- Custom aliases (vim → nvim)

## Customization

Feel free to modify any configuration files after installation. The main files are:
- `~/.config/nvim/init.lua` - Neovim configuration
- `~/.tmux.conf` - Tmux configuration
- `~/.zshrc` - Zsh configuration
- `~/.config/starship.toml` - Starship prompt configuration

## Troubleshooting

### Fonts not displaying correctly
- Ensure your terminal is configured to use JetBrains Mono Nerd Font
- On Linux, run `fc-cache -fv` to refresh font cache

### Tmux plugins not loading
- Make sure TPM is installed: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
- Press `Ctrl-a + I` inside tmux to install plugins

### Neovim plugins not installing
- Check `:Lazy` for plugin status
- Ensure you have a stable internet connection
- Try `:Lazy sync` to force plugin synchronization

## Supported Platforms

- macOS (with Homebrew)
- Linux (Debian/Ubuntu, Fedora, Arch)

## License

MIT License - See nvim/LICENSE.md for details
