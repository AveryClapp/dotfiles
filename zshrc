# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.  # Initialization code that may require console input (password prompts, [y/n] confirmations, etc.) must go above this block; everything else may go below.

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode auto      # update automatically without asking
HIST_STAMPS="mm/dd/yyyy"
#ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
git
macos
tmux
)


source $ZSH/oh-my-zsh.sh
# Preferred editor for local and remote sessions

compile() {
    g++ -std=c++17 -O2 -Wall "$1" -o sol; ./sol
}

alias vim='nvim'
alias ta='tmux attach -t'

alias gs='git status'
alias gd='git diff'
alias gp='git push'
alias gpf='git push --force'
alias ga='git add .'
alias gc='git commit -m'
#alias setup_recoll='install_name_tool -add_rpath /opt/homebrew/lib /opt/homebrew/bin/recoll'
#alias pi='ssh averyclapp@192.168.50.135'
cmake_vim_configure(){
    cp build/compile_commands.json .
}

cmake_create() {
    local build_type=${1:-Debug} # Default to Debug build
    conan install . --build=missing -of=build -s build_type=Debug # Download/setup dependencies
    cmake --preset conan-release       # Configure build system  
    cmake --build --preset conan-release  # Compile code
}

cmake_update () {
    cmake --build --preset conan-release # Compile code, no need to setup and configure build system
}

copy_file() {
    cat "$1" | pbcopy
}
run_research() {
	ssh -Y -i ~/Documents/aclapp1.pem ec2-user@"$1"
}
get_profile() {
	scp -i ~/Documents/aclapp1.pem ec2-user@"$1":~/cuda_work/tests/profile.ncu-rep ~/Documents/School/Research/NVIDIA\ Nsight\ Compute/
}

eval "$(starship init zsh)"

#export DYLD_LIBRARY_PATH=/opt/homebrew/lib:$DYLD_LIBRARY_PATH
#export RECOLL_DATADIR=/opt/homebrew/share/recoll/
# Replace your current NVM loading code with this
nvm() {
    unset -f nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    nvm "$@"
}

# Optional: Pre-define commonly used node commands to auto-load NVM
node() {
    unset -f node
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    node "$@"
}

npm() {
    unset -f npm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    npm "$@"
}

export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
