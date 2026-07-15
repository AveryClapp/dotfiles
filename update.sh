#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="full"
NO_SUDO=0
DRY_RUN=0
SKIP_EMACS=0
SKIP_ALACRITTY=0
AGENT_TOOLS=0
SYNC_GHOSTTY=0
SKIP_PERSONAL_SKILLS=0
PERSONAL_SKILLS_DIR="${PERSONAL_SKILLS_DIR:-$(cd "$DOTFILES_DIR/.." && pwd)/agent-skills}"

usage() {
  cat <<'EOF'
Usage: ./update.sh [options]

Profiles:
  --profile full        Sync the full workstation config (default).
  --profile ssh, --ssh  Sync terminal config; skip Alacritty, Emacs, and Doom.
  --profile agent       SSH-style config plus agent workflow config and skills.
  --profile agent-workstation
                        Full config plus agent workflow config and Ghostty.

Options:
  --agent               Add agent config to the selected full/ssh profile.
  --ghostty             Sync Ghostty config (does not remove Alacritty).
  --no-sudo             Accepted for parity; config sync never uses sudo.
  --skip-emacs          Skip Doom config and daemon files.
  --skip-alacritty      Skip Alacritty config.
  --skip-personal-skills
                        Do not publish skills from sibling ../agent-skills.
  --dry-run             Print destinations without changing files.
  -h, --help            Show this help.
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        shift
        [[ $# -gt 0 ]] || { printf 'error: --profile requires a value\n' >&2; exit 2; }
        PROFILE="$1"
        ;;
      --profile=*) PROFILE="${1#*=}" ;;
      --ssh|--cli) PROFILE="ssh" ;;
      --agent) AGENT_TOOLS=1 ;;
      --ghostty) SYNC_GHOSTTY=1 ;;
      --no-sudo) NO_SUDO=1 ;;
      --skip-emacs) SKIP_EMACS=1 ;;
      --skip-alacritty) SKIP_ALACRITTY=1 ;;
      --skip-personal-skills) SKIP_PERSONAL_SKILLS=1 ;;
      --dry-run) DRY_RUN=1 ;;
      -h|--help) usage; exit 0 ;;
      *) printf 'error: unknown option: %s\n' "$1" >&2; usage; exit 2 ;;
    esac
    shift
  done

  case "$PROFILE" in
    full) ;;
    ssh)
      SKIP_EMACS=1
      SKIP_ALACRITTY=1
      ;;
    agent)
      AGENT_TOOLS=1
      SKIP_EMACS=1
      SKIP_ALACRITTY=1
      ;;
    agent-workstation)
      AGENT_TOOLS=1
      SYNC_GHOSTTY=1
      ;;
    *) printf 'error: unknown profile: %s\n' "$PROFILE" >&2; exit 2 ;;
  esac
}

sync_file() {
  local src="$1" dest="$2"
  printf '  %s -> %s\n' "$src" "$dest"
  [[ "$DRY_RUN" -eq 1 ]] && return
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
}

sync_executable() {
  sync_file "$1" "$2"
  [[ "$DRY_RUN" -eq 1 ]] || chmod +x "$2"
}

sync_tree() {
  local src="$1" dest="$2"
  printf '  %s/ -> %s/\n' "$src" "$dest"
  [[ "$DRY_RUN" -eq 1 ]] && return
  mkdir -p "$dest"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete --delete-excluded \
      --exclude='.git' \
      --exclude='.claude/settings.local.json' \
      "$src/" "$dest/"
  else
    rm -rf "$dest"
    mkdir -p "$dest"
    (cd "$src" && tar --exclude='./.git' --exclude='./.claude/settings.local.json' -cf - .) \
      | (cd "$dest" && tar -xf -)
  fi
}

link_skill() {
  local src="$1" dest="$2"
  printf '  %s -> %s (symlink)\n' "$src" "$dest"
  [[ "$DRY_RUN" -eq 1 ]] && return
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" ]]; then
    ln -sfn "$src" "$dest"
  elif [[ -e "$dest" ]]; then
    printf '  warning: preserving existing skill path %s\n' "$dest" >&2
  else
    ln -s "$src" "$dest"
  fi
}

publish_shared_skills() {
  local src name
  for src in "$HOME/.agents/skills"/*; do
    [[ -d "$src" ]] || continue
    name="${src##*/}"
    link_skill "$src" "$HOME/.claude/skills/$name"
    link_skill "$src" "$HOME/.codex/skills/$name"
  done
}

publish_personal_skills() {
  [[ "$SKIP_PERSONAL_SKILLS" -eq 0 ]] || return
  local src name
  if [[ ! -d "$PERSONAL_SKILLS_DIR/skills" ]]; then
    printf '  warning: personal skill source is missing: %s/skills\n' "$PERSONAL_SKILLS_DIR" >&2
    return
  fi
  for src in "$PERSONAL_SKILLS_DIR/skills"/*; do
    [[ -d "$src" && -f "$src/SKILL.md" ]] || continue
    name="${src##*/}"
    link_skill "$src" "$HOME/.agents/skills/$name"
  done
}

sync_doom() {
  [[ "$SKIP_EMACS" -eq 1 ]] && return
  printf '  %s/ -> %s (symlink)\n' "$DOTFILES_DIR/doom" "$HOME/.config/doom"
  [[ "$DRY_RUN" -eq 1 ]] && return
  rm -rf "$HOME/.config/doom"
  ln -sfn "$DOTFILES_DIR/doom" "$HOME/.config/doom"
}

sync_emacs_service() {
  [[ "$SKIP_EMACS" -eq 1 ]] && return
  if [[ "$(uname)" == "Darwin" ]]; then
    local dest="$HOME/Library/LaunchAgents/com.averyclapp.emacs.plist"
    local emacs_bin
    emacs_bin="$(command -v emacs 2>/dev/null || printf '/opt/homebrew/bin/emacs')"
    printf '  launchd/com.averyclapp.emacs.plist -> %s\n' "$dest"
    [[ "$DRY_RUN" -eq 1 ]] && return
    mkdir -p "$(dirname "$dest")"
    sed -e "s|/Users/averyclapp|$HOME|g" \
      -e "s|/opt/homebrew/bin/emacs|$emacs_bin|g" \
      "$DOTFILES_DIR/launchd/com.averyclapp.emacs.plist" >"$dest"
  else
    sync_file "$DOTFILES_DIR/launchd/emacs.service" "$HOME/.config/systemd/user/emacs.service"
    if [[ "$DRY_RUN" -eq 0 ]] && command -v systemctl >/dev/null 2>&1; then
      systemctl --user daemon-reload
    fi
  fi
}

sync_agent_config() {
  [[ "$AGENT_TOOLS" -eq 1 ]] || return

  sync_file "$DOTFILES_DIR/agent/workmux.yaml" "$HOME/.config/workmux/config.yaml"
  publish_personal_skills
  publish_shared_skills

  printf '  agent/AGENTS.md -> %s (with machine-local additions)\n' "$HOME/.codex/AGENTS.md"
  [[ "$DRY_RUN" -eq 1 ]] && return

  mkdir -p "$HOME/.codex" "$HOME/.config/dotfiles"
  if [[ ! -e "$HOME/.config/dotfiles/agent.local.md" ]]; then
    cp "$DOTFILES_DIR/agent/agent.local.md.example" "$HOME/.config/dotfiles/agent.local.md"
  fi
  {
    cat "$DOTFILES_DIR/agent/AGENTS.md"
    if [[ -s "$HOME/.config/dotfiles/agent.local.md" ]]; then
      printf '\n'
      cat "$HOME/.config/dotfiles/agent.local.md"
    fi
  } >"$HOME/.codex/AGENTS.md"
}

main() {
  parse_args "$@"

  printf 'Syncing dotfiles (profile: %s%s)\n' "$PROFILE" "$([[ "$NO_SUDO" -eq 1 ]] && printf ', no-sudo')"
  sync_file "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
  sync_file "$DOTFILES_DIR/aliases" "$HOME/.aliases"
  sync_file "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
  sync_file "$DOTFILES_DIR/tmux.conf" "$HOME/.config/tmux/tmux.conf"
  sync_executable "$DOTFILES_DIR/bin/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
  sync_executable "$DOTFILES_DIR/bin/tmux-worktree" "$HOME/.local/bin/tmux-worktree"
  sync_executable "$DOTFILES_DIR/bin/dotfiles-doctor" "$HOME/.local/bin/dotfiles-doctor"
  if [[ "$AGENT_TOOLS" -eq 1 ]]; then
    for script in agent agent-init agent-new agent-send agent-capture agent-status agent-check agent-review agent-land agent-gc agent-doctor; do
      sync_executable "$DOTFILES_DIR/bin/$script" "$HOME/.local/bin/$script"
    done
  fi
  if [[ "$DRY_RUN" -eq 0 ]]; then
    mkdir -p "$HOME/.config/dotfiles"
    printf '%s\n' "$DOTFILES_DIR" >"$HOME/.config/dotfiles/repo"
    if [[ ! -e "$HOME/.config/dotfiles/local.bash" ]]; then
      cp "$DOTFILES_DIR/local.bash.example" "$HOME/.config/dotfiles/local.bash"
      printf '  initialized %s (future syncs preserve it)\n' "$HOME/.config/dotfiles/local.bash"
    fi
    if [[ "$(uname)" == "Darwin" ]]; then
      git config --file "$HOME/.gitconfig.local" core.fsmonitor true
    fi
  fi
  sync_tree "$DOTFILES_DIR/clangd" "$HOME/.config/clangd"
  sync_tree "$DOTFILES_DIR/taskwarrior-tui" "$HOME/.config/taskwarrior-tui"
  sync_tree "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  sync_agent_config

  if [[ "$SKIP_ALACRITTY" -eq 0 ]]; then
    sync_file "$DOTFILES_DIR/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
  fi
  if [[ "$SYNC_GHOSTTY" -eq 1 ]]; then
    sync_tree "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"
    if [[ "$DRY_RUN" -eq 0 && ! -e "$HOME/.config/dotfiles/ghostty.local" ]]; then
      cp "$DOTFILES_DIR/ghostty/local.example" "$HOME/.config/dotfiles/ghostty.local"
      printf '  initialized %s (future syncs preserve it)\n' "$HOME/.config/dotfiles/ghostty.local"
    fi
  fi
  sync_doom
  sync_emacs_service

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'Dry run complete; no files were changed.\n'
  else
    ln -sfn "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"
    printf "Done. Run 'exec bash' to reload the shell and 'tmux source ~/.config/tmux/tmux.conf' to reload tmux.\n"
  fi
}

main "$@"
