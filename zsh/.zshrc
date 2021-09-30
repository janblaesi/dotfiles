###############################################################################
# history

HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000000
SAVEHIST=1000000000

setopt bang_hist	   	# treat ! specially during expansion
setopt extended_history    	# write to the history file in :start:elapsed;command format
setopt inc_append_history  	# write history file immediately, not on shell close
setopt share_history   		# share history between all sessions
setopt hist_expire_dups_first 	# expire dups first
setopt hist_ignore_dups		# ignore duplicate entries
setopt hist_ignore_all_dups 	# delete old recorded entry if it was recorded again
setopt hist_find_no_dups 	# dont display a line previously found
setopt hist_ignore_space 	# ignore entries starting with a space
setopt hist_save_no_dups 	# dont write duplicates to history file
setopt hist_reduce_blanks 	# remove excess blanks
setopt hist_verify		# dont execute immediately upon hist expansion

###############################################################################
# prompt

autoload -U promptinit
promptinit

MY_PROMPT="%F{white}[%B%F{green}%n%F{white}@%F{cyan}%m%F{white}%b] %F{yellow}%1~%F{white}"

typeset -g PS1="$MY_PROMPT %# %b%f%k"
typeset -g PS2="$MY_PROMPT %_> %b%f%k"
typeset -g PS3="$MY_PROMPT ?# %b%f%k"

if [ -f /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh ]; then
 	. /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh
fi

###############################################################################
# vcs status

if [ -f "$( which git )" ] && [ -f ~/.git-prompt.sh ]; then
	export GIT_PS1_SHOWDIRTYSTATE="yes"
	export GIT_PS1_SHOWSTASHSTATE="yes"
	export GIT_PS1_SHOWUNTRACKEDFILES="yes"
	export GIT_PS1_SHOWCOLORHINTS="yes"
	source ~/.git-prompt.sh
	RPROMPT='$(__git_ps1 "%s")'
fi

###############################################################################
# completion

autoload -Uz compinit
compinit

unsetopt menu_complete
unsetopt flowcontrol
setopt auto_menu
setopt complete_in_word
setopt always_to_end

zstyle ':completion:*:*:*:*:*' menu select

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Complete . and .. special directories
zstyle ':completion:' special-dirs true

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

zstyle ':completion:*' rehash true

zstyle '*' single-ignored show

autoload -U +X bashcompinit && bashcompinit

###############################################################################
# term title

function term_set_title()
{
	emulate -L zsh
	local term_is_known=0
	local term_is_multiplexer=0

	if [[ ${TERM} == rxvt-unicode* || ${TERM} == xterm* || ! -z ${TMUX} ]]; then
		term_is_known=1
	fi
	if [[ ! -z ${TMUX} ]]; then
		term_is_multiplexer=1
	fi

	if [[ ${term_is_known} -ne 1 ]]; then return; fi

	printf '\033]0;%s\007' ${1//[^[:print:]]/}

	if [[ ${term_is_multiplexer} -eq 1 ]]; then
		printf '\033k%s\033\\' ${1//[^[:print:]]/}
	fi
}

function term_title_get_cmd()
{
	emulate -L zsh
	local job_text
	local job_key
	typeset -g RETURN_CMD
	RETURN_CMD=${1}

	case ${1} in
		%*) job_key=$1 ;;
		fg) job_key=%+ ;;
		fg*) job_key=${(Q)${(z)1}[2,-1]} ;;
		*) job_key='' ;;
	esac
	if [[ -z ${job_key} ]]; then return; fi

	job_text=${jobtexts[$job_key]} 2>/dev/null
	if [[ -z ${job_text} ]]; then return; fi

	RETURN_CMD=${job_texŧ}
}

function term_title_precmd()
{
	emulate -L zsh
	local cmd='zsh'
	local dir='%~'
	term_set_title ${cmd}:${(%)dir}	
}

function term_title_preexec()
{
	emulate -L zsh
	term_title_get_cmd ${1}
	local cmd=${RETURN_CMD}
	local dir='%~'
	term_set_title ${cmd}:${(%)dir}
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd term_title_precmd
add-zsh-hook preexec term_title_preexec

###############################################################################
# misc opts

setopt auto_cd
setopt multios
setopt prompt_subst

###############################################################################
# env vars

export EDITOR='vim'
export PATH="${PATH}:${HOME}/.local/bin:${HOME}/.cargo/bin"

###############################################################################
# functions and aliases

# insecure ssh functions, we only want to use those if connecting to
# some development host, where host key checking is not useful, 
# never use this to connect to something over the internet as it 
# basically defeats ssh security
function sshi()
{
	/usr/bin/ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $@
}
function scpi()
{
	/usr/bin/scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $@
}

function ssht()
{
	/usr/bin/ssh -t $@ "tmux new -A -s jbl_ssh"
}

# ssh functions for easier asta access
function _asta-ssh()
{
	local user="${1}"
	local host="${2}"

	local jump=""
	if [ "${3}" != "" ]; then
		jump="-J ${3}"
	fi

	echo "/usr/bin/ssh ${jump} ${user}@${host}"
	/usr/bin/ssh ${jump} ${user}@${host}
}
function asta-ssh()
{
	 if [ "${2}" != "" ]; then
		 _asta-ssh "blaesi" "${1}" "${2}"
	 else
		 _asta-ssh "blaesi" "${1}"
	 fi
}
function asta-sshr()
{
	 if [ "${2}" != "" ]; then
		 _asta-ssh "root" "${1}" "${2}"
	 else
		 _asta-ssh "root" "${1}"
	 fi
}

export LSCOLORS="Gxfxcxdxbxegedabagacad"

alias ls='ls --color=auto'

alias ll='ls -lh'
alias la='ls -alh'
alias l='ls -alh'

alias grep='grep --color=auto'
alias diff='diff --color=auto'

alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# gentoo-specifics
# we only enable these aliases if a gentoo system is detected
if [ -f /etc/gentoo-release ]; then
    PREFIX=""
    if [ "$UID" != "0" ]; then
        PREFIX="sudo "
    fi

    function eselect-repo-sync()
    {
        # check for existence of eselect repository module
        if ! eselect repository > /dev/null 2>&1; then
            echo "eselect repository module is not installed. skipping..."
            return
        fi

        for REPO in $( eselect repository list -i | awk '$2 !~ /^(gentoo|repositories:)$/ { print $2 }' ); do
            if [ "${UID}" != "0" ]; then
                sudo emaint sync -r "${REPO}"
            else
                emaint sync -r "${REPO}"
            fi
        done
    }

    function es()
    {
        if [ "${UID}" != "0" ]; then
            sudo emerge-webrsync
            eselect-repo-sync
        else
            emerge-webrsync
            eselect-repo-sync
        fi

        # only update eix cache if eix is installed
        if which eix > /dev/null; then
            if [ "${UID}" != "0" ]; then
                sudo eix-update
            else
                eix-update
            fi
        fi
    }

    alias e="${PREFIX}emerge"
    alias eu="${PREFIX}emerge -uDN --with-bdeps=y @world"
    alias ec="${PREFIX}emerge -c"
    alias etu="${PREFIX}etc-update"
    alias equ='equery uses'
    alias eqy='equery keywords'
    alias gli="${PREFIX}genlop -i"
fi

###############################################################################
# ssh agent load

export SSH_ENV="$HOME/.ssh/agent-environment"

function start_ssh_agent()
{
	/usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
	chmod 600 "${SSH_ENV}"
	. "${SSH_ENV}" > /dev/null
	/usr/bin/ssh-add
}

if [ ! -n "${SSH_AUTH_SOCK}" ] && [ ! -n "${SSH_CLIENT}" ] && [ ! -n "${SSH_TTY}" ]; then
	if [ -f "${SSH_ENV}" ]; then
	        . "${SSH_ENV}" > /dev/null
	        ps ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || start_ssh_agent
	else
	        start_ssh_agent
	fi
fi

###############################################################################
# load nvm if available

if [ -f ~/.nvm/nvm.sh ]; then
	source ~/.nvm/nvm.sh
fi

###############################################################################
# keybindings

autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search

autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

bindkey -v
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^R' history-incremental-search-backward

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-beginning-search
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-beginning-search
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}" reverse-menu-complete


# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx; }
	function zle_application_mode_stop { echoti rmkx; }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

if [ "$( hostname )" = "intelburner" ]; then
	export VDPAU_DRIVER=radeonsi
fi

