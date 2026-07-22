#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_home="$(mktemp -d)"
trap 'rm -rf "$test_home"' EXIT

export HOME="$test_home"
mkdir -p "$HOME/.config/dotfiles"
printf '8766\n' >"$HOME/.config/dotfiles/agent-mail-port"

# Load the installer functions without running its main entry point.
# shellcheck source=/dev/null
source <(sed '/^main "$@"$/d' "$repo_root/setup_config.sh")

call_log="$test_home/am-calls"
am() {
    printf '%s\n' "$*" >>"$call_log"
}
command_exists() {
    [[ "$1" == "am" ]]
}
agent_mail_endpoint_healthy() {
    [[ "$1" == "8766" ]]
}

configure_agent_mail >/dev/null

config_line="$(grep -nFx 'config set-port 8766' "$call_log" | cut -d: -f1)"
setup_line="$(grep -nF 'setup run --yes --no-hooks --host 127.0.0.1 --port 8766' "$call_log" | cut -d: -f1)"

[[ -n "$config_line" ]]
[[ -n "$setup_line" ]]
[[ "$config_line" -lt "$setup_line" ]]
