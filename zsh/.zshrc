export ZSH="${HOME}/.oh-my-zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"
DISABLE_AUTO_UPDATE=true
plugins=(
	git
	cp 
	colorize
	ssh-agent
	iterm2
	brew 
	docker
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

export EDITOR='vim'


# macOS likes to SendEnv LC_*...
# Linux clients get fucked up by that, so we disable it by using our local config
SSH=/usr/bin/ssh
SSH_OPTS=
if [ "$( uname )" = "Darwin" ]; then
	SSH_OPTS=(-F ${HOME}/.ssh/config)
fi

function ssh()
{
	$SSH $SSH_OPTS $@
}

function tmux-ssh()
{
	$SSH $SSH_OPTS -t $@ "tmux new -A -s jbl_ssh"
}
function asta-ssh()
{
	$SSH $SSH_OPTS -J asta $@
}

# insecure ssh functions, we only want to use those if connecting to
# some development host, where host key checking is not useful, 
# never use this to connect to something over the internet as it 
# basically defeats ssh security
function sshi()
{
	$SSH $SSH_OPTS -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $@
}
function scpi()
{
	$SSH $SSH_OPTS -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $@
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Machine-specific specialities
if [ -f "${HOME}/.zshenv" ]; then
	. "$HOME/.zshenv"
fi

