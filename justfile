set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# Full verification contract used by humans and agents.
check: syntax config lint security

# Parse every maintained shell entry point.
syntax:
    @bash -n bashrc aliases setup_config.sh update.sh
    @for file in bin/*; do bash -n "$file"; done

# Parse structured configuration without modifying it.
config:
    @python3 -c "import tomllib; tomllib.load(open('alacritty.toml', 'rb')); tomllib.load(open('.mise.toml', 'rb')); tomllib.load(open('.gitleaks.toml', 'rb'))"
    @socket="${TMPDIR:-/tmp}/dotfiles-tmux-check-$$.sock"; trap 'tmux -S "$socket" kill-server >/dev/null 2>&1 || true; rm -f "$socket"' EXIT; output="$(tmux -S "$socket" -f tmux.conf start-server \; show-options -g 2>&1)"; if [[ ! -S "$socket" ]]; then printf '%s\n' "$output" >&2; exit 1; fi

# Run pinned shell analysis and compile every Neovim Lua file.
lint:
    @mise exec -- shellcheck -x -S warning bashrc aliases setup_config.sh update.sh bin/*
    @nvim --headless -u NONE -i NONE "+lua for _, file in ipairs(vim.fn.glob('nvim/**/*.lua', false, true)) do assert(loadfile(file), file) end" +qa

# Scan tracked and untracked, non-ignored files without exposing secret values.
security:
    @tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT; while IFS= read -r -d '' file; do [[ -f "$file" ]] || continue; mkdir -p "$tmp/$(dirname "$file")"; cp -P "$file" "$tmp/$file"; done < <(git ls-files -co --exclude-standard -z); mise exec -- gitleaks dir --redact --no-banner "$tmp"

# Preview the complete local agent workstation profile.
agent-dry-run:
    @./setup_config.sh --profile agent-workstation --skill-pack all --dry-run --yes

# Sync the agent profile without downloading packages.
agent-sync:
    @./update.sh --profile agent-workstation

# Install this repository's staged-secret hook. No pre-push hook is configured.
hooks:
    @mise exec -- lefthook install

doctor:
    @./bin/dotfiles-doctor
    @./bin/agent-doctor
