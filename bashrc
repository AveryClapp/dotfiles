# ── Homebrew (hardcoded, no subprocess fork) ──────────────────────────────────
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# ── PATH ───────────────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="~/Documents/Coding/GitProjects/Claude-Code/Fallback:$PATH"
export PATH="$PATH:/Users/averyclapp/.moose/bin"
export PATH="$PATH:/usr/local/mongodb/bin"

# ── Environment ────────────────────────────────────────────────────────────────
export DYLD_LIBRARY_PATH=/opt/homebrew/lib:$DYLD_LIBRARY_PATH
export RECOLL_DATADIR=/opt/homebrew/share/recoll/
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export GIT_PAGER='delta'

# ── Rust / local env ───────────────────────────────────────────────────────────
. "$HOME/.cargo/env"
. "$HOME/.local/bin/env"

# ── History ────────────────────────────────────────────────────────────────────
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups:erasedups
if [[ -n "$BASH_VERSION" ]]; then
  shopt -s histappend
  shopt -s cdspell    # auto-correct minor typos in cd
  shopt -s nocaseglob # case-insensitive glob
  # bash 4+ only (macOS system bash is 3.2)
  if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
    shopt -s dirspell # auto-correct typos in dir completion
    shopt -s globstar # enable ** recursive glob
  fi
fi
PROMPT_COMMAND="history -a; history -c; history -r${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# --- MANPAGER ------------------------------------------------------------------
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ── EDITOR ────────────────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim

# ── BAT ────────────────────────────────────────────────────────────────
export BAT_THEME="Catppuccin-mocha"

# ── Completion ─────────────────────────────────────────────────────────────────
if [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
  source /opt/homebrew/etc/profile.d/bash_completion.sh
fi

if [ -f /usr/share/bash-completion/completions/git ]; then
  . /usr/share/bash-completion/completions/git
fi

if [[ -n "$BASH_VERSION" ]]; then
  bind 'set completion-ignore-case on'    # case-insensitive tab complete
  bind 'set completion-map-case on'       # treat - and _ as same
  bind 'set show-all-if-ambiguous on'     # show options on first tab instead of bell
  bind 'set colored-stats on'             # color file type in completion list
  bind 'set colored-completion-prefix on' # color the typed prefix in list
  bind 'set mark-symlinked-directories on'
  bind 'set menu-complete-display-prefix on'
  bind 'TAB:menu-complete'              # cycle through matches like zsh
  bind '"\e[Z":menu-complete-backward'  # shift-tab to go backward
  bind '"\e[A":history-search-backward' # up arrow: search history by typed prefix
  bind '"\e[B":history-search-forward'  # down arrow: search history by typed prefix
fi

# ── Cached init scripts ────────────────────────────────────────────────────────
# Regenerates only when the binary is newer than the cache file
_cached_eval() {
  local name="$1"
  shift
  local cache="$HOME/.cache/bash_${name}_init.sh"
  local bin
  bin="$(command -v "$name" 2>/dev/null)" || return
  if [[ ! -f "$cache" || "$bin" -nt "$cache" ]]; then
    mkdir -p "$HOME/.cache"
    "$bin" "$@" >"$cache" 2>/dev/null
  fi
  source "$cache"
}

_cached_eval starship init bash
_cached_eval zoxide init bash

# fzf
_fzf_cache="$HOME/.cache/bash_fzf_init.sh"
_fzf_bin="$(command -v fzf 2>/dev/null)"
if [[ -n "$_fzf_bin" ]]; then
  if [[ ! -f "$_fzf_cache" || "$_fzf_bin" -nt "$_fzf_cache" ]]; then
    mkdir -p "$HOME/.cache"
    "$_fzf_bin" --bash >"$_fzf_cache" 2>/dev/null
  fi
  source "$_fzf_cache"
fi
unset _fzf_cache _fzf_bin

# ── Aliases ────────────────────────────────────────────────────────────────────
alias vim='nvim'
alias ta='tmux attach -t'
alias lg='lazygit'
alias tasks='taskwarrior-tui'

alias gs='git status'
alias gd='git diff'
alias gp='git push'
alias gpf='git push --force'
alias ga='git add'
alias gc='git commit -m'

alias ls='eza --color=always --group-directories-first --no-git'
alias ll='eza -la --color=always --group-directories-first --no-git'
alias lt='eza --tree --color=always --level=2 --no-git'

# ── Functions ──────────────────────────────────────────────────────────────────
compile() {
  g++ -std=c++17 -O2 -Wall "$1" -o sol
  ./sol
}

cmake_vim_configure() {
  cp build/compile_commands.json .
}

cmake_create() {
  local build_type=${1:-Debug}
  conan install . --build=missing -of=build -s build_type=$build_type
  local preset_name
  preset_name="$(echo "$build_type" | tr '[:upper:]' '[:lower:]')"
  cmake --preset "conan-${preset_name}"
  cmake --build --preset "conan-${preset_name}"
}

cmake_update() {
  cmake --build --preset conan-release
}

copy_file() {
  cat "$1" | pbcopy
}

cppdev() {
  ssh -i ~/Documents/Coding/keys-n-pems/c++dev.pem ubuntu@"$1"
}

predlogin() {
  ssh -i ~/Documents/Coding/keys-n-pems/c++dev.pem ec2-user@"$1"
}

run_research() {
  ssh -Y -i ~/Documents/aclapp1.pem ec2-user@"$1"
}

get_profile() {
  scp -i ~/Documents/aclapp1.pem ec2-user@"$1":~/ESMM-Research/"$2" \
    ~/Documents/School/Research/NVIDIA\ Nsight\ Compute/
}

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
  [[ -n "$pid" ]] && echo "$pid" | xargs kill -${1:-9}
}

# Fuzzy git checkout branch
fbr() {
  local branch
  branch=$(git branch -a | fzf | sed 's/remotes\/origin\///' | xargs) && git checkout "$branch"
}

# Fuzzy git log
flog() {
  git log --oneline --color=always |
    fzf --ansi --preview 'git show --color=always {1}' |
    awk '{print $1}' |
    xargs git show
}

# ── Conda (lazy-loaded on first use) ──────────────────────────────────────────
conda() {
  unset -f conda
  __conda_setup="$('/Users/averyclapp/miniconda3/bin/conda' 'shell.bash' 'hook' 2>/dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "/Users/averyclapp/miniconda3/etc/profile.d/conda.sh" ]; then
      . "/Users/averyclapp/miniconda3/etc/profile.d/conda.sh"
    else
      export PATH="/Users/averyclapp/miniconda3/bin:$PATH"
    fi
  fi
  unset __conda_setup
  conda "$@"
}
