export ZSH="$HOME/.oh-my-zsh"
HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode auto
HIST_STAMPS="mm/dd/yyyy"

plugins=(
git
macos
tmux
)

source $ZSH/oh-my-zsh.sh

compile() {
    g++ -std=c++17 -O2 -Wall "$1" -o sol; ./sol
}

alias vim='nvim'
alias ta='tmux attach -t'

alias gs='git status'
alias gd='git diff'
alias gp='git push'
alias gpf='git push --force'
alias ga='git add'
alias gc='git commit -m'
#alias setup_recoll='install_name_tool -add_rpath /opt/homebrew/lib /opt/homebrew/bin/recoll'
alias tasks='taskwarrior-tui'
alias ugrad='ssh aclapp1@ugrad18.cs.jhu.edu'

cmake_vim_configure(){
    cp build/compile_commands.json .
}

cmake_create() {
    local build_type=${1:-Debug}
    conan install . --build=missing -of=build -s build_type=$build_type

    local preset_name="$(echo $build_type | tr '[:upper:]' '[:lower:]')"

    cmake --preset conan-${preset_name}
    cmake --build --preset conan-${preset_name}
}

cmake_update () {
    cmake --build --preset conan-release
}

copy_file() {
    cat "$1" | pbcopy
}

cppdev() {
    ssh -i ~/Documents/Coding/c++dev.pem ubuntu@"$1"
}

run_research() {
    ssh -Y -i ~/Documents/aclapp1.pem ec2-user@"$1"
}
get_profile() {
    scp -i ~/Documents/aclapp1.pem ec2-user@"$1":~/ESMM-Research/profile.ncu-rep ~/Documents/School/Research/NVIDIA\ Nsight\ Compute/
}

eval "$(starship init zsh)"

export DYLD_LIBRARY_PATH=/opt/homebrew/lib:$DYLD_LIBRARY_PATH
export RECOLL_DATADIR=/opt/homebrew/share/recoll/

export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="~/Documents/Coding/GitProjects/Claude-Code/Fallback:$PATH"
export PATH="$PATH:/Users/averyclapp/.moose/bin"
eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"
eval "$(/Users/averyclapp/.local/bin/mise activate zsh)"

source <(fzf --zsh)

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

alias lg="lazygit"

# Fuzzy cd into any directory
fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git | fzf --preview 'ls -la {}') && cd "$dir"
}

# Fuzzy open file in nvim
fv() {
  local file
  file=$(fzf --preview 'bat --color=always --style=numbers {}') && nvim "$file"
}

# Fuzzy kill process
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

# Fuzzy git checkout branch
fbr() {
  local branch
  branch=$(git branch -a | fzf | sed 's/remotes\/origin\///' | xargs) && git checkout "$branch"
}

# Fuzzy git log - browse commits
flog() {
  git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' | awk '{print $1}' | xargs git show
}
