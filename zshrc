export ZSH="$HOME/.oh-my-zsh"

HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode auto      # update automatically without asking
HIST_STAMPS="mm/dd/yyyy"

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
cmake_vim_configure(){
    cp build/compile_commands.json .
}

cmake_create() {
    local build_type=${1:-Debug} # Default to Debug build
    conan install . --build=missing -of=build -s build_type=$build_type # Download/setup dependencies
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


export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
