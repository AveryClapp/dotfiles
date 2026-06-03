#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp "$DOTFILES_DIR/bashrc"                   ~/.bashrc
cp "$DOTFILES_DIR/aliases"                  ~/.aliases
cp "$DOTFILES_DIR/gitconfig"                ~/.gitconfig
cp "$DOTFILES_DIR/alacritty.toml"           ~/.config/alacritty/alacritty.toml
cp "$DOTFILES_DIR/tmux.conf"                ~/.config/tmux/tmux.conf
cp "$DOTFILES_DIR/bin/tmux-sessionizer"     ~/.local/bin/tmux-sessionizer
cp "$DOTFILES_DIR/bin/tmux-worktree"        ~/.local/bin/tmux-worktree
cp -r "$DOTFILES_DIR/clangd/."              ~/.config/clangd/
cp -r "$DOTFILES_DIR/taskwarrior-tui"       ~/.config/taskwarrior-tui/
if [[ "$(uname)" == "Darwin" ]]; then
  cp "$DOTFILES_DIR/launchd/com.averyclapp.emacs.plist" ~/Library/LaunchAgents/
else
  mkdir -p ~/.config/systemd/user
  cp "$DOTFILES_DIR/launchd/emacs.service" ~/.config/systemd/user/emacs.service
  systemctl --user daemon-reload
  systemctl --user enable --now emacs.service
fi
rsync -a --exclude='.git' "$DOTFILES_DIR/nvim/" ~/.config/nvim/

echo "Done. Run 'source ~/.aliases' and 'tmux source ~/.config/tmux/tmux.conf' to reload live."
