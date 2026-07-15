# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091

# Interactive configuration only. Login profiles may source this file from
# automation, where Readline bindings, completions, and prompt hooks do not apply.
[[ $- == *i* ]] || return 0

# ── Homebrew (hardcoded, no subprocess fork) ──────────────────────────────────
if [[ -x /opt/homebrew/bin/brew ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -x /usr/local/bin/brew ]]; then
  export HOMEBREW_PREFIX="/usr/local"
fi
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
  export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
  export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
  export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
fi

# ── PATH ───────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
[[ -d "${HOMEBREW_PREFIX:-}/opt/llvm/bin" ]] && export PATH="$HOMEBREW_PREFIX/opt/llvm/bin:$PATH"

# ── Environment ────────────────────────────────────────────────────────────────
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  export DYLD_LIBRARY_PATH="$HOMEBREW_PREFIX/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
  [[ -d "$HOMEBREW_PREFIX/share/recoll" ]] && export RECOLL_DATADIR="$HOMEBREW_PREFIX/share/recoll/"
fi
_fd_bin="fd"
command -v "$_fd_bin" >/dev/null 2>&1 || _fd_bin="fdfind"
if command -v "$_fd_bin" >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="$_fd_bin --type f --hidden --exclude .git --exclude node_modules --exclude .venv --exclude target --exclude build --exclude dist"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$_fd_bin --type d --hidden --exclude .git --exclude node_modules --exclude .venv --exclude target --exclude build --exclude dist"
fi
unset _fd_bin
export GIT_PAGER='delta'

# ── Rust / local env ───────────────────────────────────────────────────────────
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
[[ -r "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# ── History ────────────────────────────────────────────────────────────────────
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups:erasedups
if [[ -n "$BASH_VERSION" ]]; then
  shopt -s histappend
  shopt -s cdspell    # auto-correct minor typos in cd
  shopt -s nocaseglob # case-insensitive glob
  shopt -s checkwinsize
  # bash 4+ only (macOS system bash is 3.2)
  if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
    shopt -s autocd   # typing a directory name cd's into it
    shopt -s dirspell # auto-correct typos in dir completion
    shopt -s globstar # enable ** recursive glob
  fi
  if ((BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 3))); then
    shopt -s direxpand # expand variables/tilde during completion
  fi
fi
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# --- MANPAGER ------------------------------------------------------------------
command -v bat >/dev/null 2>&1 && export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ── EDITOR ────────────────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim

# ── BAT ────────────────────────────────────────────────────────────────
export BAT_THEME="Catppuccin Mocha"

# ── Readline completion behaviour ─────────────────────────────────────────────
if [[ -n "$BASH_VERSION" ]]; then
  bind 'set completion-ignore-case on'    # case-insensitive tab complete
  bind 'set completion-map-case on'       # treat - and _ as same
  bind 'set show-all-if-ambiguous on'     # show list on first tab when ambiguous
  bind 'set show-all-if-unmodified on'    # show list on repeated tab even if unchanged
  bind 'set colored-stats on'             # color file type in completion list
  bind 'set colored-completion-prefix on' # color the typed prefix in list
  bind 'set mark-symlinked-directories on'
  bind 'TAB:complete'                      # first tab: complete + show visible list
  bind '"\e[Z":menu-complete'              # shift-tab: cycle forward through matches
  bind '"\e[Z\e[Z":menu-complete-backward' # shift-tab x2: cycle backward
  bind '"\e[A":history-search-backward'    # up arrow: search history by typed prefix
  bind '"\e[B":history-search-forward'     # down arrow: search history by typed prefix
fi

# ── Cached init scripts ────────────────────────────────────────────────────────
# Regenerates only when the binary is newer than the cache file
_cached_eval() {
  local name="$1"
  shift
  local cache="$HOME/.cache/bash_${name}_init.sh" tmp
  local bin
  bin="$(command -v "$name" 2>/dev/null)" || return
  if [[ ! -f "$cache" || "$bin" -nt "$cache" ]]; then
    mkdir -p "$HOME/.cache"
    tmp="${cache}.tmp.$$"
    if "$bin" "$@" 2>/dev/null >"$tmp"; then
      mv "$tmp" "$cache"
    else
      rm -f "$tmp"
      return
    fi
  fi
  source "$cache"
}

# mise supplies per-project tools and environment without a shell-startup scan.
_cached_eval mise activate bash

# Load fzf before command-specific completions. Otherwise fzf can replace
# Git's context-aware completion with generic path completion.
_fzf_cache="$HOME/.cache/bash_fzf_init.sh"
_fzf_bin="$(command -v fzf 2>/dev/null)"
if [[ -n "$_fzf_bin" ]]; then
  if [[ ! -f "$_fzf_cache" || "$_fzf_bin" -nt "$_fzf_cache" ]]; then
    mkdir -p "$HOME/.cache"
    _fzf_tmp="${_fzf_cache}.tmp.$$"
    if "$_fzf_bin" --bash 2>/dev/null >"$_fzf_tmp"; then
      mv "$_fzf_tmp" "$_fzf_cache"
    else
      rm -f "$_fzf_tmp"
    fi
  fi
  [[ -r "$_fzf_cache" ]] && source "$_fzf_cache"
fi
unset _fzf_cache _fzf_bin _fzf_tmp

# ── Completions (cached / direct — replaces oh-my-bash) ───────────────────────
# git — try brew bash-completion, then CLT fallback (static source, no fork)
for _p in \
  "${HOMEBREW_PREFIX:-}/share/bash-completion/completions/git" \
  "/usr/share/bash-completion/completions/git" \
  "/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash"; do
  [[ -f "$_p" ]] && {
    source "$_p"
    break
  }
done
unset _p

# brew / gh / pip3 — run once, cache; invalidate when binary updates
_cached_eval brew completion bash
_cached_eval gh completion -s bash
_cached_eval pip3 completion --bash
_cached_eval workmux completions bash
_cached_eval just --completions bash
_cached_eval cass completions bash

# ── Sudo plugin: double-ESC to prepend/strip sudo ─────────────────────────────
_sudo_cmd() {
  [[ -z $READLINE_LINE ]] && READLINE_LINE=$(fc -ln -1)
  if [[ $READLINE_LINE == sudo\ * ]]; then
    READLINE_LINE="${READLINE_LINE#sudo }"
  else
    READLINE_LINE="sudo $READLINE_LINE"
  fi
  READLINE_POINT=${#READLINE_LINE}
}
bind -x '"\e\e": _sudo_cmd'

_cached_eval zoxide init bash
_cached_eval direnv hook bash

# ── Prompt ─────────────────────────────────────────────────────────────────────
# Fish-style path: ~/D/C/G/dotfiles (no subprocess)
_prompt_path() {
  local path="$PWD" parts=() result="" i
  [[ "$path" == "$HOME"* ]] && path="~${path:${#HOME}}"
  IFS='/' read -ra parts <<<"$path"
  for ((i = 0; i < ${#parts[@]} - 1; i++)); do
    [[ -n "${parts[i]}" ]] && result+="${parts[i]:0:1}/"
  done
  printf '%s' "${result}${parts[-1]}"
}

# Git branch via direct .git/HEAD read (no subprocess)
_prompt_git() {
  local dir="$PWD" head
  while [[ -n "$dir" && "$dir" != / ]]; do
    if [[ -r "$dir/.git/HEAD" ]]; then
      read -r head <"$dir/.git/HEAD"
      [[ "$head" == ref:* ]] && printf '  %s' "${head##*/heads/}"
      return
    fi
    dir="${dir%/*}"
  done
}

_set_ps1() {
  local e=$?
  local blue='\[\e[38;2;127;180;202m\]'    # springBlue
  local violet='\[\e[38;2;147;138;169m\]'  # springViolet1
  local green='\[\e[1;38;2;118;148;106m\]' # autumnGreen
  local red='\[\e[1;38;2;232;36;36m\]'     # samuraiRed
  local reset='\[\e[0m\]'
  local char_color
  [[ $e -eq 0 ]] && char_color="$green" || char_color="$red"
  PS1="${blue}$(_prompt_path)${reset}${violet}$(_prompt_git)${reset}\n${char_color}❯${reset} "
}

PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_set_ps1"

# Cargo/rustup completions (not in oh-my-bash, generated and cached)
if command -v rustup &>/dev/null; then
  _rust_cache="$HOME/.cache/bash_rustup_init.sh"
  _rust_tmp="${_rust_cache}.tmp"
  _rustup_bin="$(command -v rustup)"
  if [[ ! -f "$_rust_cache" || "$_rustup_bin" -nt "$_rust_cache" ]]; then
    mkdir -p "$HOME/.cache"
    if rustup completions bash >"$_rust_tmp" 2>/dev/null \
      && rustup completions bash cargo >>"$_rust_tmp" 2>/dev/null; then
      mv "$_rust_tmp" "$_rust_cache"
    else
      rm -f "$_rust_tmp" "$_rust_cache"
    fi
  fi
  [[ -r "$_rust_cache" ]] && source "$_rust_cache"
  unset _rust_cache _rust_tmp _rustup_bin
fi

# ── SSH Agent ───────────────────────────────────────���──────────────────────────
# Respect forwarded and OS-managed agents. Only create a private agent when no
# usable socket is available, and never prompt for a key during shell startup.
if [[ -z "${SSH_AUTH_SOCK:-}" && -z "${SSH_CONNECTION:-}" ]] && command -v ssh-agent >/dev/null 2>&1; then
  _ssh_env="$HOME/.ssh/agent.env"
  [[ -r "$_ssh_env" ]] && source "$_ssh_env" >/dev/null
  if [[ -z "${SSH_AGENT_PID:-}" ]] || ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
    mkdir -p "$HOME/.ssh"
    ssh-agent | sed 's/^echo/#echo/' >"$_ssh_env"
    chmod 600 "$_ssh_env"
    source "$_ssh_env" >/dev/null
  fi
  unset _ssh_env
fi

# ── Aliases ────────────────────────────────────────────────────────────────────
[ -f ~/.aliases ] && source ~/.aliases

# Give aliases Git's parser instead of filename completion.
if declare -F __git_complete >/dev/null 2>&1; then
  __git_complete gs _git_status
  __git_complete gd _git_diff
  __git_complete gp _git_push
  __git_complete gpf _git_push
  __git_complete ga _git_add
  __git_complete gc _git_commit
  __git_complete gl _git_log
  __git_complete gco _git_checkout
  __git_complete gb _git_branch
fi

# ── Functions ──────────────────────────────────────────────────────────────────
_dot_path() {
  local dots="$1" depth path i
  [[ "$dots" == ..* && "$dots" != *[!.]* ]] || return 1
  depth=$((${#dots} - 1))
  path=".."
  for ((i = 1; i < depth; i++)); do
    path+="/.."
  done
  printf '%s\n' "$path"
}

cd() {
  local dest
  if [[ $# -eq 1 ]]; then
    dest="$(_dot_path "$1")" && {
      builtin cd "$dest" || return
      return 0
    }
  fi
  builtin cd "$@" || return
}

up() {
  local count="${1:-1}" dest=".." i
  [[ "$count" =~ ^[0-9]+$ && "$count" -gt 0 ]] || {
    printf 'usage: up [count]\n' >&2
    return 2
  }
  for ((i = 1; i < count; i++)); do
    dest+="/.."
  done
  builtin cd "$dest" || return
}

mkcd() {
  [[ $# -eq 1 ]] || {
    printf 'usage: mkcd <dir>\n' >&2
    return 2
  }
  mkdir -p "$1" || return
  cd "$1" || return
}

croot() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    printf 'not in a git repo\n' >&2
    return 1
  }
  cd "$root" || return
}

j() {
  if declare -F z >/dev/null 2>&1; then
    z "$@"
  else
    cd "$@" || return
  fi
}

ji() {
  if declare -F zi >/dev/null 2>&1; then
    zi "$@"
  else
    fcd
  fi
}

_nav_dirs() {
  local fd_bin="fd"
  command -v "$fd_bin" >/dev/null 2>&1 || fd_bin="fdfind"
  if command -v "$fd_bin" >/dev/null 2>&1; then
    "$fd_bin" --type d --hidden \
      --exclude .git \
      --exclude node_modules \
      --exclude .venv \
      --exclude target \
      --exclude build \
      --exclude dist
  else
    find . \
      \( -name .git -o -name node_modules -o -name .venv -o -name target -o -name build -o -name dist \) -prune \
      -o -type d -print
  fi
}

compile() {
  g++ -std=c++17 -O2 -Wall "$1" -o sol
  ./sol
}

cmake_vim_configure() {
  ln -sf build/compile_commands.json compile_commands.json
}

cmake_create() {
  local build_type=${1:-Debug}
  conan install . --build=missing -of=build -s build_type="$build_type"
  local preset_name
  preset_name="$(echo "$build_type" | tr '[:upper:]' '[:lower:]')"
  cmake --preset "conan-${preset_name}"
  cmake --build --preset "conan-${preset_name}"
}

cmake_update() {
  cmake --build --preset conan-release
}

copy_file() {
  [[ $# -eq 1 ]] || {
    printf 'usage: copy_file <path>\n' >&2
    return 2
  }
  if command -v pbcopy >/dev/null 2>&1; then
    pbcopy <"$1"
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard <"$1"
  else
    printf 'no clipboard command found (pbcopy or xclip)\n' >&2
    return 1
  fi
}

# Fuzzy cd into any directory
fcd() {
  local dir
  dir=$(_nav_dirs | fzf --height=40% --preview 'eza -la --group-directories-first --no-git --color=always {} 2>/dev/null || ls -la {}') || return
  cd "$dir" || return
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
  [[ -n "$pid" ]] && echo "$pid" | xargs kill -"${1:-9}"
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
  local conda_bin="" candidate
  for candidate in \
    "$HOME/miniconda3/bin/conda" \
    "$HOME/anaconda3/bin/conda" \
    "$HOME/mambaforge/bin/conda"; do
    if [[ -x "$candidate" ]]; then
      conda_bin="$candidate"
      break
    fi
  done
  [[ -n "$conda_bin" ]] || {
    printf 'conda is not installed in a standard user location\n' >&2
    return 127
  }
  unset -f conda
  if __conda_setup="$("$conda_bin" shell.bash hook 2>/dev/null)"; then
    eval "$__conda_setup"
  else
    if [[ -f "${conda_bin%/bin/conda}/etc/profile.d/conda.sh" ]]; then
      source "${conda_bin%/bin/conda}/etc/profile.d/conda.sh"
    else
      export PATH="${conda_bin%/conda}:$PATH"
    fi
  fi
  unset __conda_setup
  conda "$@"
}

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ -r "$HOME/.opam/opam-init/init.sh" ]] && source "$HOME/.opam/opam-init/init.sh" >/dev/null 2>&1
# END opam configuration

# Machine-specific paths, credentials, and helpers belong here. The installer
# and updater never overwrite this file.
[[ -r "$HOME/.config/dotfiles/local.bash" ]] && source "$HOME/.config/dotfiles/local.bash"
