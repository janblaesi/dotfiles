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
prompt adam2

if [ -f /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh ]; then
  . /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh
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

zstyle '*' single-ignored show

autoload -U +X bashcompinit && bashcompinit

###############################################################################
# misc opts

setopt auto_cd
setopt multios
setopt prompt_subst

###############################################################################
# env vars

export EDITOR='vim'

###############################################################################
# functions and aliases

# insecure ssh functions, we only want to use those if connecting to
# some development host, where host key checking is not useful, 
# never use this to connect to something over the internet as it 
# basically defeats ssh security
sshi()
{
  /usr/bin/ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $@
}
scpi()
{
  /usr/bin/scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $@
}

ssht()
{
  /usr/bin/ssh -t $@ "tmux new -A -n jbl_ssl"
}

if [ "$( uname -s )" = "Linux" ]; then
  alias ls='ls --color=auto'
elif [ "$( uname -s )" = "Darwin" ]; then
  alias ls='ls -G'
fi

alias ll='ls -lh'
alias la='ls -alh'
alias l='ls -alh'

alias grep='grep --color=auto'
alias diff='diff --color=auto'

# gentoo-specifics
# we only enable these aliases if a gentoo system is detected
if [ -f /etc/gentoo-release ]; then
    PREFIX=""
    if [ "$UID" != "0" ]; then
        PREFIX="sudo "
    fi
    alias e="${PREFIX}emerge"
    alias eu="${PREFIX}emerge -uDN --with-bdeps=y @world"
    alias ec="${PREFIX}emerge -c"
    alias es="${PREFIX}sh -c 'emerge-webrsync; eix-update'"
    alias etu="${PREFIX}etc-update"
    alias equ='equery uses'
    alias eqy='equery keywords'
    alias gli="${PREFIX}genlop -i"
fi

###############################################################################
# ssh agent load

export SSH_ENV="$HOME/.ssh/agent-environment"

start_ssh_agent()
{
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
  chmod 600 "${SSH_ENV}"
  . "${SSH_ENV}" > /dev/null
  /usr/bin/ssh-add
}

if [ -f "${SSH_ENV}" ]; then
  . "${SSH_ENV}" > /dev/null
  ps ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || start_ssh_agent
else
  start_ssh_agent
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
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

