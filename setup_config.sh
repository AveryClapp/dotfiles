#!/bin/bash

set -e  # Exit on error

echo "Starting dotfiles setup..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Install Neovim
install_neovim() {
    echo "Installing Neovim..."
    if [[ "$OS" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            echo "Homebrew not found. Please install Homebrew first."
            exit 1
        fi
        brew install neovim
    elif [[ "$OS" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo add-apt-repository ppa:neovim-ppa/unstable -y
            sudo apt update
            sudo apt install -y neovim
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y neovim
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm neovim
        else
            echo "Unsupported package manager. Please install Neovim manually."
            exit 1
        fi
    fi
}

# Install dependencies
install_dependencies() {
    echo "Installing dependencies..."
    
    if [[ "$OS" == "macos" ]]; then
        brew install tmux zsh git ripgrep fd unzip make gcc curl wget
    elif [[ "$OS" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y tmux zsh git ripgrep fd-find unzip make gcc curl wget xclip
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tmux zsh git ripgrep fd-find unzip make gcc curl wget xclip
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm tmux zsh git ripgrep fd unzip make gcc curl wget xclip
        fi
    fi
}

# Install fonts
install_fonts() {
    echo "Installing JetBrains Mono Nerd Font..."
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download font
    curl -L -o JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"
    
    # Install font based on OS
    if [[ "$OS" == "macos" ]]; then
        unzip -q JetBrainsMono.zip -d ~/Library/Fonts/
    elif [[ "$OS" == "linux" ]]; then
        mkdir -p ~/.local/share/fonts
        unzip -q JetBrainsMono.zip -d ~/.local/share/fonts/
        fc-cache -fv ~/.local/share/fonts/
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    echo "Installing Oh My Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "Oh My Zsh already installed."
    fi
}

# Install Starship
install_starship() {
    echo "Installing Starship..."
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        echo "Starship already installed."
    fi
}

# Install TPM (Tmux Plugin Manager)
install_tpm() {
    echo "Installing Tmux Plugin Manager..."
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    else
        echo "TPM already installed."
    fi
}

# Backup existing configs
backup_configs() {
    echo "Backing up existing configurations..."
    BACKUP_DIR="$HOME/.config/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # List of files/dirs to backup
    configs=(
        "$HOME/.zshrc"
        "$HOME/.tmux.conf"
        "$HOME/.config/nvim"
        "$HOME/.config/starship.toml"
    )
    
    for config in "${configs[@]}"; do
        if [ -e "$config" ]; then
            echo "Backing up $config..."
            cp -r "$config" "$BACKUP_DIR/"
        fi
    done
    
    if [ "$(ls -A $BACKUP_DIR)" ]; then
        echo "Backups saved to: $BACKUP_DIR"
    else
        rm -rf "$BACKUP_DIR"
    fi
}

# Copy configurations
copy_configs() {
    echo "Copying configuration files..."
    
    # Ensure config directory exists
    mkdir -p ~/.config
    
    # Copy files
    cp tmux.conf ~/.tmux.conf
    cp zshrc ~/.zshrc
    cp starship.toml ~/.config/starship.toml
    
    # Copy nvim directory
    if [ -d "nvim" ]; then
        cp -r nvim ~/.config/
    else
        echo "Warning: nvim directory not found in current directory"
    fi
}

# Main installation
main() {
    # Check if we're in the right directory
    if [ ! -f "setup_config.sh" ]; then
        echo "Error: Please run this script from the dotfiles directory"
        exit 1
    fi
    
    echo "=== Dotfiles Setup Script ==="
    echo "OS detected: $OS"
    echo ""
    
    # Ask for confirmation
    read -p "This will install packages and overwrite existing configs. Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    # Run installation steps
    install_dependencies
    install_neovim
    install_fonts
    install_oh_my_zsh
    install_starship
    install_tpm
    backup_configs
    copy_configs
    
    echo ""
    echo "=== Installation Complete! ==="
    echo ""
    echo "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Open tmux and press Ctrl-a + I to install tmux plugins"
    echo "3. Open nvim and wait for plugins to install automatically"
    echo ""
    echo "Note: You may need to change your default shell to zsh:"
    echo "  chsh -s $(which zsh)"
    echo ""
    
    # Check if zsh is default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        read -p "Would you like to change your default shell to zsh now? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            chsh -s $(which zsh)
            echo "Default shell changed to zsh. Please log out and back in."
        fi
    fi
}

# Run main function
main
