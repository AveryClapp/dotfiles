#!/bin/bash

################################################################################
# Dotfiles Setup Script
#
# This script automates the setup of a development environment including:
# - Package dependencies (tmux, git, ripgrep, fd, eza, delta, etc.)
# - Neovim with configuration
# - Doom Emacs with configuration (+ launchd daemon on macOS, full profile)
# - Tmux with TPM (Tmux Plugin Manager)
# - JetBrains Mono Nerd Font (full profile)
# - Alacritty terminal configuration (full profile)
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
#   ./setup_config.sh --ssh
#   ./setup_config.sh --profile ssh --no-sudo
#
################################################################################

set -e
set -u
set -o pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

OS=$(detect_os)
readonly OS

PROFILE="full"
NO_SUDO=0
ASSUME_YES=0
DRY_RUN=0
SKIP_PACKAGES=0
SKIP_EMACS=0
SKIP_ALACRITTY=0
SKIP_FONTS=0
SKIP_RUST=0
SKIP_TPM=0
AGENT_TOOLS=0
INSTALL_GHOSTTY=0
SKIP_AGENT_MAIL=0
SKIP_DCG=0
SKIP_CLAUDE_PLUGINS=0
SKIP_PERSONAL_SKILLS=0
SKILL_PACKS_SET=0
SKILL_PACKS=()
PERSONAL_SKILLS_REPO="${PERSONAL_SKILLS_REPO:-https://github.com/AveryClapp/agent-skills.git}"
PERSONAL_SKILLS_DIR="${PERSONAL_SKILLS_DIR:-$(cd "$DOTFILES_DIR/.." && pwd)/agent-skills}"
AGENT_MAIL_INSTALLER_URL="https://raw.githubusercontent.com/Dicklesworthstone/mcp_agent_mail_rust/main/install.sh"
AGENT_MAIL_LINUX_X86_64_COMPAT_VERSION="${AGENT_MAIL_LINUX_X86_64_COMPAT_VERSION:-v0.3.10}"

################################################################################
# Utility Functions
################################################################################

print_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

command_exists() { command -v "$1" &>/dev/null; }

skill_pack_enabled() {
    local requested="$1" pack
    for pack in "${SKILL_PACKS[@]-}"; do
        [[ "$pack" == "$requested" ]] && return 0
    done
    return 1
}

add_skill_pack() {
    local requested="$1" pack
    case "$requested" in
        none)
            SKILL_PACKS=()
            SKILL_PACKS_SET=1
            return
            ;;
        all)
            add_skill_pack general
            add_skill_pack web
            add_skill_pack security
            add_skill_pack research
            return
            ;;
        general|web|security|research) ;;
        *)
            print_error "Unknown skill pack: $requested"
            usage
            exit 2
            ;;
    esac
    for pack in "${SKILL_PACKS[@]-}"; do
        [[ "$pack" == "$requested" ]] && return
    done
    SKILL_PACKS+=("$requested")
    SKILL_PACKS_SET=1
}

usage() {
    cat <<'EOF'
Usage: ./setup_config.sh [options]

Profiles:
  --profile full        Full local workstation setup (default)
  --profile ssh, --ssh  Terminal-only setup for SSH machines:
                        shell, git, tmux, nvim, CLI tools; no Alacritty,
                        fonts, Emacs, Doom, or launchd agent.
  --profile agent       SSH-style setup plus Beads, workmux, Agent Mail, DCG,
                        shared skills, and agent workflow commands.
  --profile agent-workstation
                        Full setup plus the agent toolchain and Ghostty. Existing
                        Alacritty and manual workflows remain installed.

Options:
  --agent               Add agent tooling to the selected full/ssh profile.
  --ghostty             Install and sync Ghostty without removing Alacritty.
  --skip-agent-mail     Skip MCP Agent Mail installation.
  --skip-dcg            Skip Destructive Command Guard installation.
  --skill-pack PACK     Install a portable skill pack for Claude and Codex.
                        Repeatable: general, web, security, research, all, none.
                        Agent profiles default to general.
  --skip-personal-skills
                        Do not clone or publish the sibling ../agent-skills repo.
  --skip-claude-plugins Skip Claude Code LSP and engineering plugins.
  --no-sudo             Skip steps that require root/sudo. On Linux this skips
                        package-manager installs and uses user-space fallbacks
                        where available, such as Neovim through mise.
  --skip-packages       Do not install packages or package-manager tools.
  --skip-emacs          Skip Emacs, Doom, Doom sync, daemon setup, and Doom config.
  --skip-alacritty      Skip Alacritty config.
  --skip-fonts          Skip Nerd Font download/install.
  --skip-rust           Skip rustup install.
  --skip-tpm            Skip Tmux Plugin Manager install.
  --dry-run             Print the selected plan without changing anything.
  -y, --yes             Do not prompt before running.
  -h, --help            Show this help.
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --profile)
                shift
                if [[ $# -eq 0 ]]; then
                    print_error "--profile requires a value"
                    exit 2
                fi
                PROFILE="$1"
                ;;
            --profile=*)
                PROFILE="${1#*=}"
                ;;
            --ssh|--cli)
                PROFILE="ssh"
                ;;
            --agent)
                AGENT_TOOLS=1
                ;;
            --ghostty)
                INSTALL_GHOSTTY=1
                ;;
            --skip-agent-mail)
                SKIP_AGENT_MAIL=1
                ;;
            --skip-dcg)
                SKIP_DCG=1
                ;;
            --skill-pack)
                shift
                if [[ $# -eq 0 ]]; then
                    print_error "--skill-pack requires a value"
                    exit 2
                fi
                AGENT_TOOLS=1
                add_skill_pack "$1"
                ;;
            --skill-pack=*)
                AGENT_TOOLS=1
                add_skill_pack "${1#*=}"
                ;;
            --skip-claude-plugins)
                SKIP_CLAUDE_PLUGINS=1
                ;;
            --skip-personal-skills)
                SKIP_PERSONAL_SKILLS=1
                ;;
            --no-sudo)
                NO_SUDO=1
                ;;
            --skip-packages)
                SKIP_PACKAGES=1
                ;;
            --skip-emacs)
                SKIP_EMACS=1
                ;;
            --skip-alacritty)
                SKIP_ALACRITTY=1
                ;;
            --skip-fonts)
                SKIP_FONTS=1
                ;;
            --skip-rust)
                SKIP_RUST=1
                ;;
            --skip-tpm)
                SKIP_TPM=1
                ;;
            --dry-run)
                DRY_RUN=1
                ;;
            -y|--yes)
                ASSUME_YES=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 2
                ;;
        esac
        shift
    done
}

apply_profile_defaults() {
    case "$PROFILE" in
        full)
            ;;
        ssh)
            SKIP_EMACS=1
            SKIP_ALACRITTY=1
            SKIP_FONTS=1
            ;;
        agent)
            AGENT_TOOLS=1
            SKIP_EMACS=1
            SKIP_ALACRITTY=1
            SKIP_FONTS=1
            ;;
        agent-workstation)
            AGENT_TOOLS=1
            INSTALL_GHOSTTY=1
            ;;
        *)
            print_error "Unknown profile: $PROFILE"
            usage
            exit 2
            ;;
    esac

    if [[ "$AGENT_TOOLS" -eq 1 && "$SKILL_PACKS_SET" -eq 0 ]]; then
        add_skill_pack general
    fi
}

skip_root_step() {
    [[ "$NO_SUDO" -eq 1 ]]
}

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
    )

    if [[ "$SKIP_ALACRITTY" -eq 0 ]]; then
        required_files+=("alacritty.toml")
    fi
    if [[ "$AGENT_TOOLS" -eq 1 ]]; then
        required_files+=("agent/AGENTS.md" "agent/workmux.yaml")
    fi

    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done

    local required_dirs=("nvim" "taskwarrior-tui" "doom")
    if [[ "$INSTALL_GHOSTTY" -eq 1 ]]; then
        required_dirs+=("ghostty")
    fi
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
    if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
        print_info "Skipping Homebrew install (--skip-packages)"
        return
    fi

    if [[ "$OS" != "macos" ]]; then return; fi

    if command_exists brew; then
        print_info "Homebrew already installed"
        return
    fi

    if skip_root_step; then
        print_warning "Homebrew not found; skipping install because --no-sudo is set"
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
    if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
        print_info "Skipping package installation (--skip-packages)"
        return
    fi

    print_info "Installing dependencies..."

    if [[ "$OS" == "macos" ]]; then
        if ! command_exists brew; then
            print_warning "Homebrew not found; skipping macOS package install"
            return
        fi
        brew install \
            tmux git gh ripgrep fd unzip make gcc curl wget jq \
            task taskwarrior-tui zoxide fzf bat lazygit \
            eza git-delta direnv entr tldr btop hyperfine bash ruff cppman \
            mise just

    elif [[ "$OS" == "linux" ]]; then
        if skip_root_step; then
            print_warning "Skipping Linux package-manager installs because --no-sudo is set"
            print_warning "Missing foundational CLI tools may need manual/user-space installation: git, tmux, ripgrep, fd, bat, eza, delta, zoxide"
            [[ "$AGENT_TOOLS" -eq 1 ]] && print_info "The agent profile will install fzf and jq in user space with mise"
        elif command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y \
                tmux git ripgrep fd-find unzip make gcc curl wget jq \
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
                tmux git ripgrep fd-find unzip make gcc curl wget jq \
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
            sudo yum install -y tmux git unzip make gcc curl wget jq xclip fontconfig task bash \
                2>/dev/null || true
            sudo yum install -y fzf bat ripgrep fd-find 2>/dev/null \
                || print_warning "Some packages not in yum repos, install manually if needed"

            if ! command_exists zoxide; then
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi
            print_warning "eza/git-delta/lazygit not in yum — install manually"

        elif command_exists pacman; then
            sudo pacman -S --noconfirm \
                tmux git ripgrep fd unzip make gcc curl wget jq \
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
    if ! command_exists ruff && command_exists pip3; then
        pip3 install --user ruff 2>/dev/null || print_warning "Could not install ruff via pip3, install manually"
    fi

    if ! command_exists mise; then
        print_info "Installing mise in user space..."
        run_user_installer "https://mise.run" \
            || print_warning "Could not install mise"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    if command_exists mise && ! command_exists just; then
        print_info "Installing just with mise..."
        mise use -g just@latest \
            || print_warning "Could not install just with mise"
        export PATH="$HOME/.local/share/mise/shims:$PATH"
    fi

    print_success "Dependencies installed"
}

install_neovim() {
    if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
        print_info "Skipping Neovim install (--skip-packages)"
        return
    fi

    if command_exists nvim && nvim --version >/dev/null 2>&1; then
        print_info "Neovim already installed, skipping..."
        return
    elif command_exists nvim; then
        print_warning "The existing nvim command is broken; reinstalling it"
    fi

    print_info "Installing Neovim..."

    if [[ "$OS" == "macos" ]]; then
        if ! command_exists brew; then
            print_warning "Homebrew not found; skipping Neovim install"
            return
        fi
        brew install neovim
    elif [[ "$OS" == "linux" ]]; then
        if skip_root_step; then
            install_neovim_user_space
        elif command_exists apt-get; then
            sudo add-apt-repository ppa:neovim-ppa/unstable -y
            sudo apt update
            sudo apt install -y neovim
        elif command_exists dnf; then
            sudo dnf install -y neovim
        elif command_exists yum; then
            sudo yum install -y neovim || install_neovim_user_space
        elif command_exists pacman; then
            sudo pacman -S --noconfirm neovim
        fi
    fi

    print_success "Neovim installed"
}

install_neovim_user_space() {
    local bin_dir="$HOME/.local/bin"
    if [[ -L "$bin_dir/nvim" && "$(readlink "$bin_dir/nvim")" == "$bin_dir/nvim.appimage" ]]; then
        print_info "Removing a stale Neovim AppImage installation"
        rm -f "$bin_dir/nvim" "$bin_dir/nvim.appimage"
        hash -r
    fi

    if command_exists mise; then
        print_info "Installing Neovim in user space with mise..."
        if mise use -g neovim@latest; then
            export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
            hash -r
            command_exists nvim && nvim --version >/dev/null 2>&1 && return 0
        fi
        print_warning "Could not install Neovim with mise; trying the official archive"
    fi

    install_neovim_archive
}

install_neovim_archive() {
    print_info "Installing Neovim from the official user-space archive..."
    local machine asset_arch asset_name url tmp_dir install_dir bin_dir
    machine="$(uname -m)"
    case "$machine" in
        x86_64|amd64) asset_arch="x86_64" ;;
        arm64|aarch64) asset_arch="arm64" ;;
        *)
            print_warning "No Neovim archive is available for architecture: $machine"
            return 1
            ;;
    esac

    asset_name="nvim-linux-${asset_arch}"
    url="https://github.com/neovim/neovim/releases/latest/download/${asset_name}.tar.gz"
    tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/nvim-install.XXXXXX")"
    install_dir="$HOME/.local/opt/nvim"
    bin_dir="$HOME/.local/bin"

    if ! curl -fL --retry 3 -o "$tmp_dir/nvim.tar.gz" "$url"; then
        rm -rf "$tmp_dir"
        print_warning "Could not download Neovim from $url"
        return 1
    fi
    if ! tar -xzf "$tmp_dir/nvim.tar.gz" -C "$tmp_dir" || \
        [[ ! -x "$tmp_dir/$asset_name/bin/nvim" ]]; then
        rm -rf "$tmp_dir"
        print_warning "The downloaded Neovim archive was invalid"
        return 1
    fi

    mkdir -p "$(dirname "$install_dir")" "$bin_dir"
    rm -rf "${install_dir}.new"
    mv "$tmp_dir/$asset_name" "${install_dir}.new"
    rm -rf "$install_dir"
    mv "${install_dir}.new" "$install_dir"
    ln -sfn "$install_dir/bin/nvim" "$bin_dir/nvim"
    rm -f "$bin_dir/nvim.appimage"
    rm -rf "$tmp_dir"
    print_success "Neovim installed to $bin_dir/nvim"
}

install_emacs() {
    if [[ "$SKIP_EMACS" -eq 1 || "$SKIP_PACKAGES" -eq 1 ]]; then
        print_info "Skipping Emacs install"
        return
    fi

    if command_exists emacs; then
        print_info "Emacs already installed, skipping..."
        return
    fi

    print_info "Installing Emacs..."
    if [[ "$OS" == "macos" ]]; then
        if ! command_exists brew; then
            print_warning "Homebrew not found; skipping Emacs install"
            return
        fi
        # emacs-plus puts emacs/emacsclient on PATH (the Doom-recommended macOS build)
        brew tap d12frosted/emacs-plus
        if brew install emacs-plus --with-native-comp; then
            ln -sf "$(brew --prefix)/opt/emacs-plus/Emacs.app" /Applications/ 2>/dev/null || true
        else
            print_warning "emacs-plus failed; falling back to cask emacs"
            brew install --cask emacs
        fi
    elif [[ "$OS" == "linux" ]]; then
        if skip_root_step; then
            print_warning "Skipping Emacs package install because --no-sudo is set"
            return
        fi
        if command_exists apt-get; then sudo apt-get install -y emacs
        elif command_exists dnf;    then sudo dnf install -y emacs
        elif command_exists yum;    then sudo yum install -y emacs || print_warning "Install emacs manually"
        elif command_exists pacman; then sudo pacman -S --noconfirm emacs
        fi
    fi
    print_success "Emacs installed"
}

install_doom() {
    if [[ "$SKIP_EMACS" -eq 1 ]]; then
        print_info "Skipping Doom install"
        return
    fi

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
    if [[ "$SKIP_EMACS" -eq 1 ]]; then
        print_info "Skipping Doom sync"
        return
    fi

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
    if [[ "$SKIP_EMACS" -eq 1 ]]; then
        print_info "Skipping Emacs daemon setup"
        return
    fi

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
    if [[ "$SKIP_FONTS" -eq 1 ]]; then
        print_info "Skipping font install"
        return
    fi

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
    if [[ "$SKIP_TPM" -eq 1 ]]; then
        print_info "Skipping TPM install"
        return
    fi

    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        print_info "TPM already installed, skipping..."
        return
    fi

    print_info "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    print_success "TPM installed"
}

install_rust() {
    if [[ "$SKIP_RUST" -eq 1 ]]; then
        print_info "Skipping Rust install"
        return
    fi

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

run_user_installer() {
    local url="$1"
    shift
    local installer status
    installer=$(mktemp)
    if ! curl -fsSL "$url" -o "$installer"; then
        rm -f "$installer"
        return 1
    fi
    if bash "$installer" "$@"; then
        status=0
    else
        status=$?
    fi
    rm -f "$installer"
    return "$status"
}

agent_mail_executable_works() {
    command_exists am && am --version >/dev/null 2>&1
}

install_agent_mail_compat() {
    [[ "$OS" == "linux" && "$(uname -m)" =~ ^(x86_64|amd64)$ ]] || return 1
    print_warning "Installing static Agent Mail $AGENT_MAIL_LINUX_X86_64_COMPAT_VERSION for Linux compatibility"
    run_user_installer \
        "${AGENT_MAIL_INSTALLER_URL}?$(date +%s)" \
        --version "$AGENT_MAIL_LINUX_X86_64_COMPAT_VERSION" --force --yes --verify
}

install_agent_mail() {
    if agent_mail_executable_works; then
        print_info "MCP Agent Mail already installed"
        return
    fi

    if command_exists am; then
        print_warning "The installed Agent Mail binary cannot run on this host"
        install_agent_mail_compat || true
    else
        run_user_installer \
            "${AGENT_MAIL_INSTALLER_URL}?$(date +%s)" \
            --yes --verify \
            || print_warning "Could not install the latest MCP Agent Mail release"
        agent_mail_executable_works || install_agent_mail_compat || true
    fi

    if agent_mail_executable_works; then
        print_success "MCP Agent Mail installed: $(am --version 2>/dev/null | head -n 1)"
    else
        print_warning "MCP Agent Mail is installed but cannot execute on this host"
    fi
}

mise_use_global() {
    command_exists mise || {
        print_warning "mise is required to install user-space agent tools"
        return 1
    }
    mise use -g "$@"
    export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
    hash -r
}

install_agent_cli_tools() {
    print_info "Installing agent CLI utilities with mise..."
    mise_use_global \
        just@latest \
        ast-grep@latest \
        fzf@latest \
        gitleaks@latest \
        jq@latest \
        lefthook@latest \
        lua-language-server@latest \
        node@lts \
        npm:pyright@latest \
        npm:typescript-language-server@latest \
        npm:typescript@latest \
        || print_warning "Some agent CLI utilities need attention; run 'agent-doctor'"

    if skill_pack_enabled web; then
        mise_use_global npm:agent-browser@latest \
            || print_warning "Could not install agent-browser"
        if command_exists agent-browser; then
            agent-browser install \
                || print_warning "Could not install the agent-browser Chromium runtime"
        fi
    fi

    if ! command_exists cass; then
        print_info "Installing CASS session search in user space..."
        run_user_installer \
            "https://raw.githubusercontent.com/Dicklesworthstone/coding_agent_session_search/main/install.sh?$(date +%s)" \
            --easy-mode --verify \
            || print_warning "Could not install CASS"
    fi
}

install_skill_source() {
    local source="$1"
    shift
    local args=(--yes skills add "$source" --global --agent claude-code --agent codex --yes)
    local skill
    for skill in "$@"; do
        args+=(--skill "$skill")
    done
    npx "${args[@]}"
}

install_portable_skill_packs() {
    [[ "$AGENT_TOOLS" -eq 1 ]] || return
    [[ -n "${SKILL_PACKS[*]-}" ]] || {
        print_info "No third-party Agent Skills selected"
        return
    }
    if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
        print_info "Skipping third-party Agent Skills (--skip-packages)"
        return
    fi
    command_exists npx || {
        print_warning "npx is unavailable; third-party Agent Skills were not installed"
        return
    }

    if skill_pack_enabled general; then
        print_info "Installing general engineering skills for Claude and Codex..."
        install_skill_source mattpocock/skills \
            grill-with-docs domain-modeling codebase-design prototype handoff resolving-merge-conflicts \
            || print_warning "Could not install the general skill pack"
    fi
    if skill_pack_enabled web; then
        print_info "Installing web engineering skills for Claude and Codex..."
        install_skill_source vercel-labs/agent-skills \
            vercel-react-best-practices web-design-guidelines \
            || print_warning "Could not install Vercel's web skill pack"
        install_skill_source vercel-labs/agent-browser agent-browser \
            || print_warning "Could not install the agent-browser skill"
    fi
    if skill_pack_enabled security; then
        print_info "Installing the Cloudflare security audit skill..."
        install_skill_source cloudflare/security-audit-skill security-audit \
            || print_warning "Could not install the security skill pack"
    fi
    if skill_pack_enabled research; then
        print_info "Installing the lightweight research skill..."
        install_skill_source mattpocock/skills research \
            || print_warning "Could not install the research skill pack"
    fi
}

install_personal_skills_repo() {
    [[ "$AGENT_TOOLS" -eq 1 && "$SKIP_PERSONAL_SKILLS" -eq 0 ]] || return
    if [[ -d "$PERSONAL_SKILLS_DIR/.git" ]]; then
        print_info "Personal skills repo already present: $PERSONAL_SKILLS_DIR"
        return
    fi
    if [[ -e "$PERSONAL_SKILLS_DIR" ]]; then
        print_warning "Personal skills path exists but is not a Git repo: $PERSONAL_SKILLS_DIR"
        return
    fi
    if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
        print_info "Personal skills repo is absent; skipping clone (--skip-packages)"
        return
    fi
    command_exists git || {
        print_warning "git is unavailable; could not clone personal skills"
        return
    }

    print_info "Cloning personal skills into $PERSONAL_SKILLS_DIR..."
    git clone --depth 1 "$PERSONAL_SKILLS_REPO" "$PERSONAL_SKILLS_DIR" \
        || print_warning "Could not clone personal skills from $PERSONAL_SKILLS_REPO"
}

claude_plugin_installed() {
    local plugin="$1"
    [[ "$CLAUDE_PLUGIN_LIST" == *"$plugin"* ]]
}

install_claude_plugin() {
    local plugin="$1"
    if claude_plugin_installed "$plugin"; then
        print_info "Claude plugin already installed: $plugin"
        return
    fi
    claude plugin install "$plugin" --scope user \
        || print_warning "Could not install Claude plugin: $plugin"
}

configure_claude_plugins() {
    [[ "$AGENT_TOOLS" -eq 1 && "$SKIP_CLAUDE_PLUGINS" -eq 0 ]] || return
    if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
        print_info "Skipping Claude plugin installation (--skip-packages)"
        return
    fi
    command_exists claude || {
        print_info "Claude Code is not installed; skipping Claude-specific plugins"
        return
    }

    print_info "Installing focused Claude Code plugins..."
    CLAUDE_PLUGIN_LIST="$(claude plugin list 2>/dev/null || true)"
    install_claude_plugin pyright-lsp@claude-plugins-official
    install_claude_plugin typescript-lsp@claude-plugins-official
    install_claude_plugin lua-lsp@claude-plugins-official
    install_claude_plugin skill-creator@claude-plugins-official
    install_claude_plugin pr-review-toolkit@claude-plugins-official
    install_claude_plugin plugin-dev@claude-plugins-official
    claude plugin disable plugin-dev@claude-plugins-official --scope user >/dev/null 2>&1 || true
    claude plugin disable academic-research-skills@academic-research-skills --scope user >/dev/null 2>&1 || true
}

install_agent_tools() {
    if [[ "$AGENT_TOOLS" -eq 0 ]]; then return; fi
    if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
        print_info "Skipping agent tool installation (--skip-packages)"
        return
    fi

    print_info "Installing agent workflow tools..."

    if [[ "$OS" == "macos" ]] && command_exists brew; then
        if brew list --formula beads >/dev/null 2>&1; then
            brew upgrade beads || true
        else
            brew install beads
        fi
        if brew list --formula workmux >/dev/null 2>&1; then
            brew upgrade workmux || true
        else
            brew install raine/workmux/workmux
        fi
    else
        run_user_installer \
            "https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh" \
            || print_warning "Could not install Beads"
        run_user_installer \
            "https://raw.githubusercontent.com/raine/workmux/main/scripts/install.sh" \
            || print_warning "Could not install workmux"
    fi

    if [[ "$SKIP_DCG" -eq 0 ]]; then
        if command_exists dcg; then
            print_info "Destructive Command Guard already installed"
        else
            run_user_installer \
                "https://raw.githubusercontent.com/Dicklesworthstone/destructive_command_guard/main/install.sh?$(date +%s)" \
                --easy-mode \
                || print_warning "Could not install Destructive Command Guard"
        fi
    fi

    if [[ "$SKIP_AGENT_MAIL" -eq 0 ]]; then
        install_agent_mail
    fi

    if ! command_exists codex && ! command_exists claude; then
        print_warning "No coding agent found; install Codex or Claude Code before using workmux"
    fi
    install_agent_cli_tools
    print_success "Agent workflow tools installed"
}

install_ghostty() {
    if [[ "$INSTALL_GHOSTTY" -eq 0 ]]; then return; fi
    if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
        print_info "Skipping Ghostty install (--skip-packages)"
        return
    fi
    if command_exists ghostty || [[ -d /Applications/Ghostty.app ]]; then
        print_info "Ghostty already installed"
        return
    fi

    print_info "Installing Ghostty..."
    if [[ "$OS" == "macos" ]] && command_exists brew; then
        brew install --cask ghostty
    elif [[ "$OS" == "linux" && "$NO_SUDO" -eq 0 ]] && command_exists pacman; then
        sudo pacman -S --noconfirm ghostty
    else
        print_warning "Ghostty package installation is not configured for this platform; config will still be synced"
        return
    fi
    print_success "Ghostty installed"
}

configure_agent_integrations() {
    [[ "$AGENT_TOOLS" -eq 1 ]] || return
    if command_exists workmux; then
        print_info "Configuring workmux agent status hooks and skills..."
        workmux setup --hooks --skills \
            || print_warning "workmux setup needs attention; run it manually"
    fi
    configure_agent_mail
}

agent_mail_endpoint_healthy() {
    local port="$1" response
    response="$(curl -fsS --max-time 2 "http://127.0.0.1:${port}/healthz" 2>/dev/null || true)"
    [[ "$response" == *'"status":"alive"'* ]]
}

localhost_port_in_use() {
    local port="$1"
    (exec 3<>"/dev/tcp/127.0.0.1/$port") >/dev/null 2>&1
}

start_agent_mail_tmux_service() {
    local port="$1" session="agent-mail-service" am_path server_command
    command_exists tmux || return 1
    am_path="$(command -v am)"

    if tmux has-session -t "$session" 2>/dev/null; then
        tmux kill-session -t "$session" || return 1
    fi
    printf -v server_command \
        'exec %q serve-http --host 127.0.0.1 --port %q --no-tui' \
        "$am_path" "$port"
    tmux new-session -d -s "$session" "$server_command"
}

configure_agent_mail() {
    [[ "$SKIP_AGENT_MAIL" -eq 0 ]] || return
    agent_mail_executable_works || {
        print_warning "Agent Mail cannot execute; skipping MCP service setup"
        return
    }

    local port_file="$HOME/.config/dotfiles/agent-mail-port"
    local preferred_port="8765" port="" candidate
    if [[ -r "$port_file" ]]; then
        read -r preferred_port <"$port_file"
        [[ "$preferred_port" =~ ^[0-9]+$ ]] || preferred_port="8765"
    fi

    for candidate in "$preferred_port" 8765 8766 8767 9000; do
        [[ "$candidate" =~ ^[0-9]+$ ]] || continue
        if agent_mail_endpoint_healthy "$candidate" || ! localhost_port_in_use "$candidate"; then
            port="$candidate"
            break
        fi
    done
    if [[ -z "$port" ]]; then
        print_warning "Could not find a free localhost port for Agent Mail"
        return
    fi

    if ! agent_mail_endpoint_healthy "$port"; then
        print_info "Starting the Agent Mail user service on 127.0.0.1:$port..."
        if am service install --host 127.0.0.1 --port "$port"; then
            for _ in {1..20}; do
                agent_mail_endpoint_healthy "$port" && break
                sleep 1
            done
        else
            print_warning "Could not install the Agent Mail user service; trying persistent tmux"
        fi
    fi

    if ! agent_mail_endpoint_healthy "$port"; then
        print_info "Starting Agent Mail in the agent-mail-service tmux session..."
        if start_agent_mail_tmux_service "$port"; then
            for _ in {1..20}; do
                agent_mail_endpoint_healthy "$port" && break
                sleep 1
            done
        fi
    fi

    if ! agent_mail_endpoint_healthy "$port"; then
        print_warning "Agent Mail did not become healthy on 127.0.0.1:$port"
        print_warning "Inspect it with 'am service status' or 'tmux capture-pane -pt agent-mail-service'"
        return
    fi

    mkdir -p "$(dirname "$port_file")"
    printf '%s\n' "$port" >"$port_file"
    print_info "Synchronizing Agent Mail MCP clients..."
    am setup run --yes --no-hooks --host 127.0.0.1 --port "$port" --project-dir "$HOME" \
        || print_warning "Agent Mail MCP client setup needs attention; run 'am setup status'"
    print_success "Agent Mail is ready on 127.0.0.1:$port"
}

configure_git_delta() {
    if [[ "$OS" == "macos" ]]; then
        git config --file "$HOME/.gitconfig.local" core.fsmonitor true
        print_success "Built-in Git filesystem monitor enabled"
    fi

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

configure_github_credentials() {
    command_exists gh || return
    if gh auth status --hostname github.com >/dev/null 2>&1; then
        print_info "Connecting Git to the authenticated GitHub CLI account..."
        if gh auth setup-git --hostname github.com; then
            print_success "GitHub credential helper configured"
        else
            print_warning "Could not configure the GitHub credential helper"
        fi
    else
        print_info "GitHub CLI is not authenticated; run 'gh auth login' when private access or pushing is needed"
    fi
}

configure_bash_default() {
    if skip_root_step; then
        print_info "Skipping default shell change because --no-sudo is set"
        return
    fi

    local bash_path
    bash_path=$(command -v bash)

    if [[ "$SHELL" == "$bash_path" ]]; then
        print_info "Default shell is already bash"
        return
    fi

    print_info "Current shell: $SHELL"
    if [[ "$ASSUME_YES" -eq 0 ]]; then
        read -r -p "Change default shell to bash? (y/N) " -n 1
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Keeping current shell. Change later with: chsh -s \$(which bash)"
            return
        fi
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

    local backup_dir
    backup_dir="$HOME/.config/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    local configs=(
        "$HOME/.bashrc"
        "$HOME/.aliases"
        "$HOME/.gitconfig"
        "$HOME/.tmux.conf"
        "$HOME/.config/tmux"
        "$HOME/.config/nvim"
        "$HOME/.config/doom"
        "$HOME/.config/alacritty"
        "$HOME/.config/ghostty"
        "$HOME/.config/workmux"
        "$HOME/.config/taskwarrior-tui"
        "$HOME/.config/clangd"
        "$HOME/.agents/skills/agentic-engineering"
        "$HOME/.agents/skills/dotfiles-maintenance"
        "$HOME/.claude/skills/agentic-engineering"
        "$HOME/.codex/skills/agentic-engineering"
        "$HOME/.codex/AGENTS.md"
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

copy_tree() {
    local src="$1"
    local dest="$2"

    rm -rf "$dest"
    mkdir -p "$dest"
    cp -R "$src"/. "$dest"/
}

copy_tree_excluding_git() {
    local src="$1"
    local dest="$2"

    rm -rf "$dest"
    mkdir -p "$dest"
    if command_exists rsync; then
        rsync -a \
            --exclude='.git' \
            --exclude='.claude/settings.local.json' \
            "$src"/ "$dest"/
    else
        (cd "$src" && tar --exclude='./.git' --exclude='./.claude/settings.local.json' -cf - .) \
            | (cd "$dest" && tar -xf -)
    fi
}

publish_skill_link() {
    local source="$1" destination="$2"
    mkdir -p "$(dirname "$destination")"
    if [[ -L "$destination" ]]; then
        ln -sfn "$source" "$destination"
    elif [[ -e "$destination" ]]; then
        print_warning "Preserving existing skill path: $destination"
    else
        ln -s "$source" "$destination"
    fi
}

publish_shared_skill_links() {
    local source name
    for source in "$HOME/.agents/skills"/*; do
        [[ -d "$source" ]] || continue
        name="${source##*/}"
        publish_skill_link "$source" "$HOME/.claude/skills/$name"
        publish_skill_link "$source" "$HOME/.codex/skills/$name"
    done
}

publish_personal_skill_links() {
    [[ "$SKIP_PERSONAL_SKILLS" -eq 0 ]] || return
    local source name destination
    if [[ ! -d "$PERSONAL_SKILLS_DIR/skills" ]]; then
        print_warning "Personal skill source is missing: $PERSONAL_SKILLS_DIR/skills"
        return
    fi
    for source in "$PERSONAL_SKILLS_DIR/skills"/*; do
        [[ -d "$source" && -f "$source/SKILL.md" ]] || continue
        name="${source##*/}"
        destination="$HOME/.agents/skills/$name"
        publish_skill_link "$source" "$destination"
    done
}

copy_configs() {
    print_info "Copying configuration files..."

    mkdir -p ~/.config ~/.config/tmux

    if [[ ! -e ~/.config/dotfiles/local.bash && -f local.bash.example ]]; then
        mkdir -p ~/.config/dotfiles
        cp local.bash.example ~/.config/dotfiles/local.bash
        print_success "local.bash initialized (future syncs will preserve it)"
    fi

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
    cp bin/dotfiles-doctor ~/.local/bin/dotfiles-doctor
    chmod +x ~/.local/bin/dotfiles-doctor
    if [[ "$AGENT_TOOLS" -eq 1 ]]; then
        local agent_script
        for agent_script in agent agent-init agent-new agent-send agent-capture agent-status agent-check agent-review agent-land agent-gc agent-doctor; do
            cp "bin/$agent_script" "$HOME/.local/bin/$agent_script"
            chmod +x "$HOME/.local/bin/$agent_script"
        done
    fi
    mkdir -p ~/.config/dotfiles
    printf '%s\n' "$(pwd)" >~/.config/dotfiles/repo
    print_success "bin/ → ~/.local/bin/"

    # Alacritty
    if [[ "$SKIP_ALACRITTY" -eq 0 ]]; then
        mkdir -p ~/.config/alacritty
        cp alacritty.toml ~/.config/alacritty/alacritty.toml
        print_success "alacritty.toml → ~/.config/alacritty/alacritty.toml"
    else
        print_info "Skipping Alacritty config"
    fi

    if [[ "$INSTALL_GHOSTTY" -eq 1 ]]; then
        copy_tree ghostty ~/.config/ghostty
        if [[ ! -e ~/.config/dotfiles/ghostty.local ]]; then
            cp ghostty/local.example ~/.config/dotfiles/ghostty.local
        fi
        print_success "ghostty/ → ~/.config/ghostty/"
    fi

    if [[ "$AGENT_TOOLS" -eq 1 ]]; then
        mkdir -p ~/.config/workmux ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.config/dotfiles
        cp agent/workmux.yaml ~/.config/workmux/config.yaml
        publish_personal_skill_links
        publish_shared_skill_links
        if [[ ! -e ~/.config/dotfiles/agent.local.md ]]; then
            cp agent/agent.local.md.example ~/.config/dotfiles/agent.local.md
        fi
        {
            cat agent/AGENTS.md
            if [[ -s ~/.config/dotfiles/agent.local.md ]]; then
                printf '\n'
                cat ~/.config/dotfiles/agent.local.md
            fi
        } >~/.codex/AGENTS.md
        print_success "agent config → workmux, shared Claude/Codex skills, and ~/.codex/AGENTS.md"
    fi

    # Neovim
    if [ -d "nvim" ]; then
        copy_tree_excluding_git nvim ~/.config/nvim
        print_success "nvim/ → ~/.config/nvim/ (without nested .git)"
    fi

    # Doom Emacs (symlink, so the repo stays the single source of truth)
    if [[ "$SKIP_EMACS" -eq 0 && -d "doom" ]]; then
        rm -rf ~/.config/doom
        ln -sfn "$(pwd)/doom" ~/.config/doom
        print_success "doom/ → ~/.config/doom (symlink)"
    elif [[ "$SKIP_EMACS" -eq 1 ]]; then
        print_info "Skipping Doom config"
    fi

    # Clangd
    if [ -d "clangd" ]; then
        mkdir -p ~/.config/clangd
        cp -r clangd/. ~/.config/clangd/
        print_success "clangd/ → ~/.config/clangd/"
    fi

    # Taskwarrior TUI
    if [ -d "taskwarrior-tui" ]; then
        copy_tree taskwarrior-tui ~/.config/taskwarrior-tui
        print_success "taskwarrior-tui/ → ~/.config/taskwarrior-tui/"
    fi

    print_success "All configuration files copied"
}

################################################################################
# Main
################################################################################

main() {
    parse_args "$@"
    apply_profile_defaults

    echo "========================================="
    echo "        Dotfiles Setup Script"
    echo "========================================="
    echo ""
    print_info "Profile: $PROFILE"
    if [[ "$NO_SUDO" -eq 1 ]]; then
        print_info "No-sudo mode: root-requiring steps will be skipped"
    fi
    echo ""

    print_info "Running pre-flight checks..."
    validate_os
    validate_directory
    validate_source_files

    echo ""
    echo "This script will:"
    echo "  1. Back up existing configurations"
    if [[ "$SKIP_PACKAGES" -eq 0 ]]; then
        echo "  2. Install terminal packages where available (tmux, nvim, eza, delta, fzf, zoxide, ...)"
    else
        echo "  2. Skip package installation"
    fi
    if [[ "$SKIP_EMACS" -eq 0 ]]; then
        echo "  3. Install Doom Emacs + start its daemon at login (macOS)"
    else
        echo "  3. Skip Emacs/Doom"
    fi
    if [[ "$SKIP_RUST" -eq 0 ]]; then
        echo "  4. Install Rust toolchain if missing"
    else
        echo "  4. Skip Rust"
    fi
    if [[ "$SKIP_FONTS" -eq 0 ]]; then
        echo "  5. Install Nerd Font"
    else
        echo "  5. Skip fonts"
    fi
    echo "  6. Install/copy tmux, shell, git, nvim, clangd, and taskwarrior configs"
    echo "  7. Configure git to use delta if available"
    if [[ "$AGENT_TOOLS" -eq 1 ]]; then
        if [[ "$SKIP_PACKAGES" -eq 0 ]]; then
            echo "  8. Install Beads, workmux, Agent Mail, DCG, agent CLIs, and workflow commands"
            if [[ "$SKIP_PERSONAL_SKILLS" -eq 0 ]]; then
                echo "     Personal skills: $PERSONAL_SKILLS_REPO -> $PERSONAL_SKILLS_DIR"
            fi
            echo "     Skill packs: ${SKILL_PACKS[*]:-none}"
            if [[ "$SKIP_CLAUDE_PLUGINS" -eq 0 ]]; then
                echo "     Claude plugins: language intelligence, skill creator, and PR review"
            fi
        else
            echo "  8. Sync shared agent config, skills, and workflow commands"
        fi
    fi
    if [[ "$INSTALL_GHOSTTY" -eq 1 ]]; then
        echo "  9. Install and configure Ghostty without removing Alacritty"
    fi
    echo ""

    if [[ "$DRY_RUN" -eq 1 ]]; then
        print_success "Dry run complete; no files or packages were changed"
        exit 0
    fi

    if [[ "$ASSUME_YES" -eq 0 ]]; then
        read -r -p "Continue? (y/N) " -n 1
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Cancelled"
            exit 0
        fi
    fi

    echo ""

    backup_configs

    install_homebrew
    install_dependencies
    install_neovim
    install_emacs
    install_doom
    install_rust
    install_fonts
    install_tpm
    install_agent_tools
    install_personal_skills_repo
    install_portable_skill_packs
    configure_claude_plugins
    install_ghostty

    copy_configs
    sync_doom
    install_emacs_daemon
    configure_github_credentials
    configure_git_delta
    configure_agent_integrations
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
    local next_step=5
    if [[ "$SKIP_EMACS" -eq 0 ]]; then
        echo "  $next_step. Run 'e' (GUI) or 'et' (terminal) → Doom Emacs, packages already synced"
        next_step=$((next_step + 1))
    fi
    if [[ "$AGENT_TOOLS" -eq 1 ]]; then
        echo "  $next_step. Run 'agent doctor', then run 'agent init' inside projects that should use Beads"
        next_step=$((next_step + 1))
        echo "  $next_step. Confirm Agent Mail with 'am service status'"
    fi
    echo ""

    if [[ "$OS" == "linux" ]]; then
        echo "Linux notes:"
        echo "  - If 'fd' not found, try 'fdfind' instead"
        if [[ "$SKIP_ALACRITTY" -eq 0 ]]; then
            echo "  - Alacritty must be installed separately on Linux"
        fi
        if command_exists yum && ! command_exists dnf; then
            echo "  - Amazon Linux 2: some packages may need manual installation"
        fi
        echo ""
    fi
}

main "$@"
