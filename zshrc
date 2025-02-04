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
aws
docker
python
pylint
npm
macos
docker
tmux
)


source $ZSH/oh-my-zsh.sh
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='vim'
fi
alias vim="nvim"
alias ta='tmux attach -t'
alias ugrad_os='ssh -X aclapp1@ugradx.cs.jhu.edu'
alias ugrad='ssh aclapp1@ugrad23.cs.jhu.edu'
alias setup_recoll='install_name_tool -add_rpath /opt/homebrew/lib /opt/homebrew/bin/recoll'
alias pi='ssh averyclapp@192.168.50.135'
run_research() {
	ssh -i ~/Documents/aclapp1.pem ec2-user@"$1"
}

eval "$(starship init zsh)"
