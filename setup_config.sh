#!/bin/bash

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

curl -L0 https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip

# MacOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Installing packages for macOS..."
    brew install tmux zsh
	unzip JetBrainsMono.ziip -d ~/Library/Fonts
	curl -sS https://starship.rs/install.sh | sh

# Linux
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Installing packages for Linux..."
    if [ -x "$(command -v apt-get)" ]; then
        # Debian/Ubuntu
        sudo apt-get update
	sudo add-apt-repository ppa:neovim-ppa/unstable -y
	sudo apt update
	sudo apt install make gcc ripgrep unzip git xclip neovim

        sudo apt-get install -y tmux zsh
		unzip JetBrainsMono.zip -d ~/.local/share/fonts
		fc-cache -fv ~/.local/share/fonts
		curl -sS https://starship.rs/install.sh | sh
    fi
else
    echo "Not a compatible OS version, must complete manually"
fi
mv tmux.conf ~/.tmux.conf
mkdir -p ~/.config
mv zshrc ~/.zshrc
mv starship.toml ~/.config/
mv nvim ~/.config/

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source ~/.tmux.conf
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
