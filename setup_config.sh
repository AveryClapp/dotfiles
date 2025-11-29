#!/bin/bash

################################################################################
# Dotfiles Setup Script
#
# This script automates the setup of a development environment including:
# - Package dependencies (tmux, zsh, git, ripgrep, fd, etc.)
# - Neovim with configuration
# - Oh My Zsh and Starship prompt
# - Tmux with TPM (Tmux Plugin Manager)
# - JetBrains Mono Nerd Font
# - Alacritty terminal with Catppuccin theme
#
# Supported Operating Systems:
# - macOS (Intel & Apple Silicon)
# - Ubuntu/Debian (apt-get)
# - Fedora/RHEL 8+ (dnf)
# - Amazon Linux 2/2023 (yum/dnf)
# - Arch Linux (pacman)
#
# Prerequisites:
# - macOS: None (Homebrew will be auto-installed if missing)
# - Linux: sudo access for package installation
#
# Usage:
#   cd /path/to/dotfiles
#   ./setup_config.sh
#
# The script will:
# 1. Detect your operating system
# 2. Validate all required source files exist
# 3. Back up your existing configurations
# 4. Install all dependencies and tools
# 5. Copy dotfiles to their appropriate locations
#
################################################################################

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error
set -o pipefail  # Prevent errors in a pipeline from being masked

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unsupported"
    fi
}

readonly OS=$(detect_os)

################################################################################
# Utility Functions
################################################################################

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

################################################################################
# Validation Functions
################################################################################

# Validate OS is supported
validate_os() {
    if [[ "$OS" == "unsupported" ]]; then
        print_error "Unsupported OS: $OSTYPE"
        print_error "This script supports macOS and Linux only."
        exit 1
    fi
    print_success "OS detected: $OS"
}

# Validate script is run from dotfiles directory
validate_directory() {
    if [ ! -f "setup_config.sh" ]; then
        print_error "Please run this script from the dotfiles directory"
        print_error "Current directory: $(pwd)"
        exit 1
    fi
    print_success "Running from correct directory: $(pwd)"
}

# Validate all required source files exist
validate_source_files() {
    print_info "Validating source configuration files..."

    local missing_files=()
    local required_files=(
        ".zshrc"
        ".taskrc"
        "tmux.conf"
        "starship.toml"
    )

    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done

    # Check required directories
    if [ ! -d "nvim" ]; then
        missing_files+=("nvim/")
    fi
    if [ ! -d "taskwarrior-tui" ]; then
        missing_files+=("taskwarrior-tui/")
    fi

    if [ ${#missing_files[@]} -gt 0 ]; then
        print_error "Missing required source files:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        exit 1
    fi

    print_success "All source files validated"
}

################################################################################
# Installation Functions
################################################################################

# Install Homebrew (macOS only)
install_homebrew() {
    if [[ "$OS" != "macos" ]]; then
        return
    fi

    if command_exists brew; then
        print_info "Homebrew already installed"
        return
    fi

    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    print_success "Homebrew installed"
}

# Install Neovim
install_neovim() {
    print_info "Installing Neovim..."

    if command_exists nvim; then
        print_warning "Neovim already installed, skipping..."
        return
    fi

    if [[ "$OS" == "macos" ]]; then
        brew install neovim
    elif [[ "$OS" == "linux" ]]; then
        if command_exists apt-get; then
            # Ubuntu/Debian - use PPA for latest version
            sudo add-apt-repository ppa:neovim-ppa/unstable -y
            sudo apt update
            sudo apt install -y neovim
        elif command_exists dnf; then
            # Fedora/RHEL 8+/Amazon Linux 2023
            sudo dnf install -y neovim
        elif command_exists yum; then
            # Amazon Linux 2/RHEL 7 - try yum first, fall back to AppImage
            if sudo yum install -y neovim; then
                print_success "Neovim installed via yum"
            else
                print_warning "Neovim not available in yum, installing AppImage..."
                install_neovim_appimage
            fi
            return
        elif command_exists pacman; then
            # Arch Linux
            sudo pacman -S --noconfirm neovim
        else
            print_error "Unsupported package manager. Please install Neovim manually."
            exit 1
        fi
    fi

    print_success "Neovim installed"
}

# Install Neovim AppImage (fallback for older distros)
install_neovim_appimage() {
    print_info "Installing Neovim AppImage..."

    local nvim_dir="$HOME/.local/bin"
    mkdir -p "$nvim_dir"

    # Download latest stable AppImage
    curl -Lo "$nvim_dir/nvim.appimage" https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x "$nvim_dir/nvim.appimage"

    # Create symlink
    ln -sf "$nvim_dir/nvim.appimage" "$nvim_dir/nvim"

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$nvim_dir:"* ]]; then
        print_info "Add the following to your shell config to use nvim:"
        print_info "export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi

    print_success "Neovim AppImage installed to $nvim_dir/nvim"
}

# Install dependencies
install_dependencies() {
    print_info "Installing dependencies..."

    if [[ "$OS" == "macos" ]]; then
        brew install tmux zsh git ripgrep fd unzip make gcc curl wget task taskwarrior-tui
    elif [[ "$OS" == "linux" ]]; then
        if command_exists apt-get; then
            # Ubuntu/Debian
            sudo apt-get update
            sudo apt-get install -y tmux zsh git ripgrep fd-find unzip make gcc curl wget xclip fontconfig taskwarrior
            # taskwarrior-tui from cargo or manual install
            if ! command_exists taskwarrior-tui; then
                print_warning "taskwarrior-tui not in apt, install via cargo or download from GitHub"
            fi
        elif command_exists dnf; then
            # Fedora/RHEL 8+/Amazon Linux 2023
            sudo dnf install -y tmux zsh git ripgrep fd-find unzip make gcc curl wget xclip fontconfig task
            if ! command_exists taskwarrior-tui; then
                print_warning "taskwarrior-tui not in dnf, install via cargo or download from GitHub"
            fi
        elif command_exists yum; then
            # Amazon Linux 2/RHEL 7/CentOS 7
            # Enable EPEL for additional packages
            if ! rpm -q epel-release &>/dev/null; then
                print_info "Enabling EPEL repository..."
                sudo yum install -y epel-release || {
                    # For Amazon Linux 2, use amazon-linux-extras
                    if command_exists amazon-linux-extras; then
                        sudo amazon-linux-extras install epel -y
                    fi
                }
            fi
            # Install packages (note: fd is 'fd-find' on some distros)
            sudo yum install -y tmux zsh git unzip make gcc curl wget xclip fontconfig task 2>/dev/null || print_warning "taskwarrior not available in yum"
            # ripgrep and fd might need EPEL or manual install
            sudo yum install -y ripgrep fd-find || {
                print_warning "Could not install ripgrep/fd via yum. Attempting alternatives..."
                # Try without the -find suffix
                sudo yum install -y fd 2>/dev/null || print_warning "fd not available, install manually if needed"
                # ripgrep might not be in repos
                if ! command_exists rg; then
                    print_warning "ripgrep not available in repositories"
                    print_info "You can install it manually from: https://github.com/BurntSushi/ripgrep/releases"
                fi
            }
        elif command_exists pacman; then
            # Arch Linux
            sudo pacman -S --noconfirm tmux zsh git ripgrep fd unzip make gcc curl wget xclip fontconfig task
            if ! command_exists taskwarrior-tui; then
                print_warning "taskwarrior-tui not in pacman, install via AUR or cargo"
            fi
        else
            print_error "Unsupported package manager"
            exit 1
        fi
    fi

    print_success "Dependencies installed"
}

# Install fonts
install_fonts() {
    print_info "Installing JetBrains Mono Nerd Font..."

    local temp_dir=$(mktemp -d)
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"

    cd "$temp_dir"

    if ! curl -L -o JetBrainsMono.zip "$font_url"; then
        print_error "Failed to download font"
        cd - >/dev/null
        rm -rf "$temp_dir"
        return 1
    fi

    if [[ "$OS" == "macos" ]]; then
        unzip -q JetBrainsMono.zip -d ~/Library/Fonts/
    elif [[ "$OS" == "linux" ]]; then
        mkdir -p ~/.local/share/fonts
        unzip -q JetBrainsMono.zip -d ~/.local/share/fonts/

        # Refresh font cache (fontconfig is now guaranteed to be installed)
        if command_exists fc-cache; then
            fc-cache -fv ~/.local/share/fonts/
        else
            print_warning "fc-cache not found, fonts may not be immediately available"
        fi
    fi

    cd - >/dev/null
    rm -rf "$temp_dir"

    print_success "Fonts installed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    print_info "Installing Oh My Zsh..."

    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_warning "Oh My Zsh already installed, skipping..."
        return
    fi

    # Install Oh My Zsh without overwriting .zshrc (we'll do that ourselves)
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    print_success "Oh My Zsh installed"
}

# Install Starship
install_starship() {
    print_info "Installing Starship..."

    if command_exists starship; then
        print_warning "Starship already installed, skipping..."
        return
    fi

    curl -sS https://starship.rs/install.sh | sh -s -- -y

    print_success "Starship installed"
}

# Install TPM (Tmux Plugin Manager)
install_tpm() {
    print_info "Installing Tmux Plugin Manager..."

    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        print_warning "TPM already installed, skipping..."
        return
    fi

    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    print_success "TPM installed"
}

# Install Catppuccin Latte theme for Alacritty
install_alacritty_theme() {
    print_info "Installing Catppuccin Latte theme for Alacritty..."

    mkdir -p ~/.config/alacritty

    if ! curl -fsSL https://raw.githubusercontent.com/catppuccin/alacritty/main/catppuccin-latte.toml -o ~/.config/alacritty/catppuccin-latte.toml; then
        print_warning "Failed to download Alacritty theme, skipping..."
        return
    fi

    # Add import to alacritty.toml if it doesn't already exist
    if [ ! -f ~/.config/alacritty/alacritty.toml ]; then
        print_info "Creating new alacritty.toml with theme import"
        cat >~/.config/alacritty/alacritty.toml <<EOF
[import]
files = ["~/.config/alacritty/catppuccin-latte.toml"]
EOF
    elif ! grep -q 'catppuccin-latte.toml' ~/.config/alacritty/alacritty.toml; then
        print_info "Adding theme import to existing alacritty.toml"
        cat >>~/.config/alacritty/alacritty.toml <<EOF

[import]
files = ["~/.config/alacritty/catppuccin-latte.toml"]
EOF
    else
        print_info "Catppuccin theme already imported in alacritty.toml"
    fi

    print_success "Alacritty theme installed"
}

################################################################################
# Backup and Configuration Functions
################################################################################

# Backup existing configs (RUNS BEFORE ANY INSTALLATIONS)
backup_configs() {
    print_info "Backing up existing configurations..."

    local backup_dir="$HOME/.config/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    local configs=(
        "$HOME/.zshrc"
        "$HOME/.taskrc"
        "$HOME/.tmux.conf"
        "$HOME/.config/nvim"
        "$HOME/.config/starship.toml"
        "$HOME/.config/alacritty"
        "$HOME/.config/taskwarrior-tui"
    )

    local backed_up=0
    for config in "${configs[@]}"; do
        if [ -e "$config" ]; then
            print_info "Backing up $config..."
            cp -r "$config" "$backup_dir/"
            backed_up=$((backed_up + 1))
        fi
    done

    if [ $backed_up -gt 0 ]; then
        print_success "Backups saved to: $backup_dir"
    else
        print_info "No existing configurations to backup"
        rm -rf "$backup_dir"
    fi
}

# Copy configurations
copy_configs() {
    print_info "Copying configuration files..."

    mkdir -p ~/.config

    # Copy dotfiles (note: source is .zshrc with leading dot)
    cp .zshrc ~/.zshrc
    cp .taskrc ~/.taskrc
    cp tmux.conf ~/.tmux.conf
    cp starship.toml ~/.config/starship.toml

    # Copy nvim directory
    if [ -d "nvim" ]; then
        # Remove existing nvim config if it exists (already backed up)
        rm -rf ~/.config/nvim
        cp -r nvim ~/.config/
        print_success "Neovim configuration copied"
    else
        print_warning "nvim directory not found, skipping..."
    fi

    # Copy taskwarrior-tui directory
    if [ -d "taskwarrior-tui" ]; then
        rm -rf ~/.config/taskwarrior-tui
        cp -r taskwarrior-tui ~/.config/
        print_success "Taskwarrior TUI configuration copied"
    else
        print_warning "taskwarrior-tui directory not found, skipping..."
    fi

    print_success "Configuration files copied"
}

# Change default shell to zsh
change_shell_to_zsh() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        print_info "Default shell is already zsh"
        return
    fi

    print_info "Current shell: $SHELL"
    read -p "Would you like to change your default shell to zsh? (y/N) " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping current shell. You can change it later with: chsh -s \$(which zsh)"
        return
    fi

    local zsh_path=$(which zsh)

    # Ensure zsh is in /etc/shells
    if ! grep -q "$zsh_path" /etc/shells; then
        print_info "Adding $zsh_path to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Change shell
    if chsh -s "$zsh_path"; then
        print_success "Default shell changed to zsh"
        print_warning "Please log out and back in for the change to take effect"
    else
        print_error "Failed to change shell. You may need to run: chsh -s \$(which zsh)"
    fi
}

################################################################################
# Main Function
################################################################################

main() {
    echo "========================================="
    echo "     Dotfiles Setup Script"
    echo "========================================="
    echo ""

    # VALIDATION PHASE - Check everything before asking user
    print_info "Running pre-flight checks..."
    validate_os
    validate_directory
    validate_source_files

    echo ""
    echo "This script will:"
    echo "  1. Back up your existing configurations"
    echo "  2. Install required packages and tools"
    echo "  3. Install Neovim, Oh My Zsh, Starship, fonts, etc."
    echo "  4. Copy dotfiles to your home directory"
    echo ""

    read -p "Continue with installation? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi

    echo ""
    print_info "Starting installation..."
    echo ""

    # BACKUP PHASE - Must happen BEFORE Oh My Zsh to preserve original .zshrc
    backup_configs

    # INSTALLATION PHASE - Order matters!
    install_homebrew        # macOS only, must be first
    install_dependencies    # Must be before anything that uses curl, git, etc.
    install_neovim
    install_fonts
    install_starship
    install_tpm
    install_oh_my_zsh      # After backup, before copy_configs

    # CONFIGURATION PHASE
    copy_configs           # Overwrites Oh My Zsh's .zshrc with our custom one
    install_alacritty_theme  # After copy_configs to avoid overwriting

    # FINALIZATION
    change_shell_to_zsh

    echo ""
    echo "========================================="
    echo "     Installation Complete!"
    echo "========================================="
    echo ""
    print_success "All components installed successfully"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Open tmux and press Ctrl-a + I to install tmux plugins"
    echo "  3. Open nvim - plugins will install automatically via lazy.nvim"
    echo ""

    if [[ "$OS" == "linux" ]]; then
        echo "Linux-specific notes:"
        echo "  - If 'fd' command not found, try 'fdfind' instead"
        echo "  - Alacritty theme requires Alacritty terminal"

        if command_exists yum && ! command_exists dnf; then
            echo "  - Amazon Linux 2/RHEL 7: Some packages may need manual installation"
            echo "  - If ripgrep missing: https://github.com/BurntSushi/ripgrep/releases"
            echo "  - Neovim AppImage installed to ~/.local/bin (ensure it's in PATH)"
        fi
        echo ""
    fi
}

################################################################################
# Script Entry Point
################################################################################

main "$@"
