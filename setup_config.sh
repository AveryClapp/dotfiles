#!/bin/bash

################################################################################
# Dotfiles Setup Script
#
# This script automates the setup of a development environment including:
# - Package dependencies (tmux, git, ripgrep, fd, eza, delta, etc.)
# - Neovim with configuration
# - Doom Emacs with configuration (+ launchd daemon on macOS)
# - Starship prompt
# - Tmux with TPM (Tmux Plugin Manager)
# - JetBrains Mono Nerd Font
# - Alacritty terminal configuration
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
################################################################################

set -e
set -u
set -o pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

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

print_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

command_exists() { command -v "$1" &>/dev/null; }

################################################################################
# Validation
################################################################################

validate_os() {
    if [[ "$OS" == "unsupported" ]]; then
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
    print_success "OS detected: $OS"
}

validate_directory() {
    if [ ! -f "setup_config.sh" ]; then
        print_error "Please run this script from the dotfiles directory"
        print_error "Current directory: $(pwd)"
        exit 1
    fi
    print_success "Running from correct directory: $(pwd)"
}

validate_source_files() {
    print_info "Validating source configuration files..."

    local missing_files=()
    local required_files=(
        "bashrc"
        "aliases"
        "tmux.conf"
        "alacritty.toml"
    )

    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done

    local required_dirs=("nvim" "taskwarrior-tui" "doom")
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            missing_files+=("$dir/")
        fi
    done

    if [ ${#missing_files[@]} -gt 0 ]; then
        print_error "Missing required source files:"
        for f in "${missing_files[@]}"; do
            echo "  - $f"
        done
        exit 1
    fi

    print_success "All source files validated"
}

################################################################################
# Installation Functions
################################################################################

install_homebrew() {
    if [[ "$OS" != "macos" ]]; then return; fi

    if command_exists brew; then
        print_info "Homebrew already installed"
        return
    fi

    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    print_success "Homebrew installed"
}

install_dependencies() {
    print_info "Installing dependencies..."

    if [[ "$OS" == "macos" ]]; then
        brew install \
            tmux git ripgrep fd unzip make gcc curl wget \
            task taskwarrior-tui zoxide fzf bat lazygit \
            eza git-delta direnv entr tldr btop hyperfine bash ruff cppman

    elif [[ "$OS" == "linux" ]]; then
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y \
                tmux git ripgrep fd-find unzip make gcc curl wget \
                xclip fontconfig taskwarrior fzf bat bash

            # eza
            if ! command_exists eza; then
                sudo mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
                    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
                    | sudo tee /etc/apt/sources.list.d/gierens.list
                sudo apt-get update
                sudo apt-get install -y eza
            fi

            # git-delta
            if ! command_exists delta; then
                local delta_deb
                delta_deb=$(mktemp --suffix=.deb)
                curl -Lo "$delta_deb" \
                    "https://github.com/dandavison/delta/releases/latest/download/git-delta_$(uname -m).deb" \
                    2>/dev/null || print_warning "Could not download git-delta, install manually"
                [[ -f "$delta_deb" ]] && sudo dpkg -i "$delta_deb" && rm "$delta_deb"
            fi

            # zoxide
            if ! command_exists zoxide; then
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi

            # lazygit
            if ! command_exists lazygit; then
                print_warning "lazygit not in apt — install from https://github.com/jesseduffield/lazygit"
            fi

            # taskwarrior-tui
            if ! command_exists taskwarrior-tui; then
                print_warning "taskwarrior-tui not in apt — install via cargo or GitHub releases"
            fi

        elif command_exists dnf; then
            sudo dnf install -y \
                tmux git ripgrep fd-find unzip make gcc curl wget \
                xclip fontconfig task fzf bat zoxide eza git-delta bash

            if ! command_exists lazygit; then
                print_warning "lazygit not in dnf — install from https://github.com/jesseduffield/lazygit"
            fi
            if ! command_exists taskwarrior-tui; then
                print_warning "taskwarrior-tui not in dnf — install via cargo or GitHub releases"
            fi

        elif command_exists yum; then
            if ! rpm -q epel-release &>/dev/null; then
                sudo yum install -y epel-release || {
                    command_exists amazon-linux-extras && sudo amazon-linux-extras install epel -y
                }
            fi
            sudo yum install -y tmux git unzip make gcc curl wget xclip fontconfig task bash \
                2>/dev/null || true
            sudo yum install -y fzf bat ripgrep fd-find 2>/dev/null \
                || print_warning "Some packages not in yum repos, install manually if needed"

            if ! command_exists zoxide; then
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi
            print_warning "eza/git-delta/lazygit not in yum — install manually"

        elif command_exists pacman; then
            sudo pacman -S --noconfirm \
                tmux git ripgrep fd unzip make gcc curl wget \
                xclip fontconfig task fzf bat zoxide lazygit eza git-delta bash

            if ! command_exists taskwarrior-tui; then
                print_warning "taskwarrior-tui — install via AUR or cargo"
            fi

        else
            print_error "Unsupported package manager"
            exit 1
        fi
    fi

    # ruff (Python formatter used by Neovim conform.nvim)
    if ! command_exists ruff; then
        pip3 install --user ruff 2>/dev/null || print_warning "Could not install ruff via pip3, install manually"
    fi

    print_success "Dependencies installed"
}

install_neovim() {
    if command_exists nvim; then
        print_info "Neovim already installed, skipping..."
        return
    fi

    print_info "Installing Neovim..."

    if [[ "$OS" == "macos" ]]; then
        brew install neovim
    elif [[ "$OS" == "linux" ]]; then
        if command_exists apt-get; then
            sudo add-apt-repository ppa:neovim-ppa/unstable -y
            sudo apt update
            sudo apt install -y neovim
        elif command_exists dnf; then
            sudo dnf install -y neovim
        elif command_exists yum; then
            sudo yum install -y neovim || install_neovim_appimage
        elif command_exists pacman; then
            sudo pacman -S --noconfirm neovim
        fi
    fi

    print_success "Neovim installed"
}

install_neovim_appimage() {
    print_info "Installing Neovim AppImage..."
    local nvim_dir="$HOME/.local/bin"
    mkdir -p "$nvim_dir"
    curl -Lo "$nvim_dir/nvim.appimage" \
        https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x "$nvim_dir/nvim.appimage"
    ln -sf "$nvim_dir/nvim.appimage" "$nvim_dir/nvim"
    print_success "Neovim AppImage installed to $nvim_dir/nvim"
}

install_emacs() {
    if command_exists emacs; then
        print_info "Emacs already installed, skipping..."
        return
    fi

    print_info "Installing Emacs..."
    if [[ "$OS" == "macos" ]]; then
        # emacs-plus puts emacs/emacsclient on PATH (the Doom-recommended macOS build)
        brew tap d12frosted/emacs-plus
        if brew install emacs-plus --with-native-comp; then
            ln -sf "$(brew --prefix)/opt/emacs-plus/Emacs.app" /Applications/ 2>/dev/null || true
        else
            print_warning "emacs-plus failed; falling back to cask emacs"
            brew install --cask emacs
        fi
    elif [[ "$OS" == "linux" ]]; then
        if command_exists apt-get; then sudo apt-get install -y emacs
        elif command_exists dnf;    then sudo dnf install -y emacs
        elif command_exists yum;    then sudo yum install -y emacs || print_warning "Install emacs manually"
        elif command_exists pacman; then sudo pacman -S --noconfirm emacs
        fi
    fi
    print_success "Emacs installed"
}

install_doom() {
    if [ -d "$HOME/.config/emacs/.git" ]; then
        print_info "Doom Emacs already installed, skipping clone..."
        return
    fi

    print_info "Cloning Doom Emacs framework..."
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    print_success "Doom framework cloned (config symlinked + synced later)"
}

# Build Doom's packages against our symlinked config. Run AFTER copy_configs.
sync_doom() {
    if [ ! -x "$HOME/.config/emacs/bin/doom" ]; then
        print_warning "Doom not installed; skipping doom sync"
        return
    fi
    print_info "Syncing Doom packages (this can take a few minutes)..."
    "$HOME/.config/emacs/bin/doom" sync || print_warning "doom sync had issues — run 'doom doctor'"
    "$HOME/.config/emacs/bin/doom" env >/dev/null 2>&1 || true
    print_success "Doom packages synced"
}

# Install the launchd agent so the Emacs daemon starts at login (macOS only).
install_emacs_daemon() {
    if [[ "$OS" != "macos" ]]; then
        print_info "Emacs daemon autostart (launchd) is macOS-only; skipping on $OS"
        return
    fi
    if [ ! -f "launchd/com.averyclapp.emacs.plist" ]; then
        print_warning "launchd plist not found; skipping daemon autostart"
        return
    fi

    print_info "Installing Emacs daemon launchd agent..."
    mkdir -p ~/Library/LaunchAgents
    local plist=~/Library/LaunchAgents/com.averyclapp.emacs.plist
    local emacs_bin
    emacs_bin=$(command -v emacs || echo /opt/homebrew/bin/emacs)
    # Rewrite the baked-in paths to this machine's $HOME and emacs binary
    sed -e "s|/Users/averyclapp|$HOME|g" \
        -e "s|/opt/homebrew/bin/emacs|$emacs_bin|g" \
        launchd/com.averyclapp.emacs.plist > "$plist"
    launchctl unload "$plist" 2>/dev/null || true
    launchctl load -w "$plist"
    print_success "Emacs daemon will start at login — use 'e' / 'et' to open frames"
}

install_fonts() {
    print_info "Installing JetBrains Mono Nerd Font..."

    local temp_dir
    temp_dir=$(mktemp -d)
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"

    if ! curl -L -o "$temp_dir/JetBrainsMono.zip" "$font_url"; then
        print_warning "Failed to download font, skipping..."
        rm -rf "$temp_dir"
        return
    fi

    if [[ "$OS" == "macos" ]]; then
        unzip -q "$temp_dir/JetBrainsMono.zip" -d ~/Library/Fonts/
    elif [[ "$OS" == "linux" ]]; then
        mkdir -p ~/.local/share/fonts
        unzip -q "$temp_dir/JetBrainsMono.zip" -d ~/.local/share/fonts/
        command_exists fc-cache && fc-cache -fv ~/.local/share/fonts/
    fi

    rm -rf "$temp_dir"
    print_success "Fonts installed"
}

install_tpm() {
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        print_info "TPM already installed, skipping..."
        return
    fi

    print_info "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    print_success "TPM installed"
}

install_oh_my_bash() {
    if [ -d "$HOME/.oh-my-bash" ]; then
        print_info "Oh My Bash already installed, skipping..."
        return
    fi

    print_info "Installing Oh My Bash..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended 2>/dev/null || true
    print_success "Oh My Bash installed to ~/.oh-my-bash"
    print_warning "Add 'source ~/.oh-my-bash/oh-my-bash.sh' to your bashrc to enable it"
}

install_rust() {
    if command_exists cargo; then
        print_info "Rust already installed, skipping..."
        return
    fi

    print_info "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
    print_success "Rust installed"
}

configure_git_delta() {
    if ! command_exists delta; then
        print_warning "git-delta not found, skipping git config..."
        return
    fi

    print_info "Configuring git to use delta..."
    git config --global core.pager delta
    git config --global interactive.diffFilter 'delta --color-only'
    git config --global delta.navigate true
    git config --global delta.side-by-side true
    git config --global merge.conflictstyle diff3
    print_success "git delta configured"
}

configure_bash_default() {
    local bash_path
    bash_path=$(command -v bash)

    if [[ "$SHELL" == "$bash_path" ]]; then
        print_info "Default shell is already bash"
        return
    fi

    print_info "Current shell: $SHELL"
    read -r -p "Change default shell to bash? (y/N) " -n 1
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping current shell. Change later with: chsh -s \$(which bash)"
        return
    fi

    if ! grep -q "$bash_path" /etc/shells; then
        echo "$bash_path" | sudo tee -a /etc/shells >/dev/null
    fi

    if chsh -s "$bash_path"; then
        print_success "Default shell changed to bash"
        print_warning "Log out and back in for the change to take effect"
    else
        print_error "Failed to change shell. Run manually: chsh -s \$(which bash)"
    fi
}

################################################################################
# Backup and Configuration
################################################################################

backup_configs() {
    print_info "Backing up existing configurations..."

    local backup_dir="$HOME/.config/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    local configs=(
        "$HOME/.bashrc"
        "$HOME/.tmux.conf"
        "$HOME/.config/tmux"
        "$HOME/.config/nvim"
        "$HOME/.config/doom"
        "$HOME/.config/alacritty"
        "$HOME/.config/taskwarrior-tui"
        "$HOME/.config/clangd"
    )

    local backed_up=0
    for config in "${configs[@]}"; do
        if [ -e "$config" ]; then
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

copy_configs() {
    print_info "Copying configuration files..."

    mkdir -p ~/.config ~/.config/tmux ~/.config/alacritty

    # Shell
    cp bashrc ~/.bashrc
    print_success "bashrc → ~/.bashrc"

    cp aliases ~/.aliases
    print_success "aliases → ~/.aliases"

    # Tmux (XDG location matches reload bind in tmux.conf)
    cp tmux.conf ~/.config/tmux/tmux.conf
    # Also symlink to ~/.tmux.conf so tmux finds it on older versions
    ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf
    print_success "tmux.conf → ~/.config/tmux/tmux.conf (+ ~/.tmux.conf symlink)"

    # Git
    cp gitconfig ~/.gitconfig
    print_success "gitconfig → ~/.gitconfig"

    # Scripts
    mkdir -p ~/.local/bin
    cp bin/tmux-sessionizer ~/.local/bin/tmux-sessionizer
    chmod +x ~/.local/bin/tmux-sessionizer
    cp bin/tmux-worktree ~/.local/bin/tmux-worktree
    chmod +x ~/.local/bin/tmux-worktree
    print_success "bin/ → ~/.local/bin/"

    # Alacritty
    cp alacritty.toml ~/.config/alacritty/alacritty.toml
    print_success "alacritty.toml → ~/.config/alacritty/alacritty.toml"

    # Neovim
    if [ -d "nvim" ]; then
        rm -rf ~/.config/nvim
        cp -r nvim ~/.config/
        print_success "nvim/ → ~/.config/nvim/"
    fi

    # Doom Emacs (symlink, so the repo stays the single source of truth)
    if [ -d "doom" ]; then
        rm -rf ~/.config/doom
        ln -sfn "$(pwd)/doom" ~/.config/doom
        print_success "doom/ → ~/.config/doom (symlink)"
    fi

    # Clangd
    if [ -d "clangd" ]; then
        mkdir -p ~/.config/clangd
        cp -r clangd/. ~/.config/clangd/
        print_success "clangd/ → ~/.config/clangd/"
    fi

    # Taskwarrior TUI
    if [ -d "taskwarrior-tui" ]; then
        rm -rf ~/.config/taskwarrior-tui
        cp -r taskwarrior-tui ~/.config/
        print_success "taskwarrior-tui/ → ~/.config/taskwarrior-tui/"
    fi

    print_success "All configuration files copied"
}

################################################################################
# Main
################################################################################

main() {
    echo "========================================="
    echo "        Dotfiles Setup Script"
    echo "========================================="
    echo ""

    print_info "Running pre-flight checks..."
    validate_os
    validate_directory
    validate_source_files

    echo ""
    echo "This script will:"
    echo "  1. Back up existing configurations"
    echo "  2. Install packages (tmux, nvim, emacs, eza, delta, fzf, bat, lazygit, zoxide, ...)"
    echo "  3. Install Doom Emacs + start its daemon at login (macOS)"
    echo "  3. Install Oh My Bash"
    echo "  4. Install Rust toolchain"
    echo "  5. Install fonts and TPM"
    echo "  5. Copy dotfiles to their destinations"
    echo "  6. Configure git to use delta"
    echo ""

    read -r -p "Continue? (y/N) " -n 1
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        exit 0
    fi

    echo ""

    backup_configs

    install_homebrew
    install_dependencies
    install_neovim
    install_emacs
    install_doom
    install_oh_my_bash
    install_rust
    install_fonts
    install_tpm

    copy_configs
    sync_doom
    install_emacs_daemon
    configure_git_delta
    configure_bash_default

    echo ""
    echo "========================================="
    echo "        Installation Complete!"
    echo "========================================="
    echo ""
    print_success "All components installed successfully"
    echo ""
    echo "Next steps:"
    echo "  1. source ~/.bashrc"
    echo "  2. Open tmux → prefix + I to install plugins"
    echo "  3. Open nvim → plugins install automatically via lazy.nvim"
    echo "  4. In nvim run :Lazy sync to ensure everything is up to date"
    echo "  5. Run 'e' (GUI) or 'et' (terminal) → Doom Emacs, packages already synced"
    echo ""

    if [[ "$OS" == "linux" ]]; then
        echo "Linux notes:"
        echo "  - If 'fd' not found, try 'fdfind' instead"
        echo "  - Alacritty must be installed separately on Linux"
        if command_exists yum && ! command_exists dnf; then
            echo "  - Amazon Linux 2: some packages may need manual installation"
        fi
        echo ""
    fi
}

main "$@"
