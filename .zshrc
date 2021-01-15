
# Detect if we are local or remote.
export SESSION_TYPE="local"
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	SESSION_TYPE="remote/ssh"
else
	case $(ps -o comm= -p $PPID) in
		sshd|*/sshd) SESSION_TYPE=remote/ssh;;
	esac
fi

echo "Session Type: $SESSION_TYPE"

# Are we in a shared acount?
export SESSION_SHARED=true
if [ "$USER" = "milo" ]; then
	SESSION_SHARED=false
fi

if $SESSION_SHARED; then
	echo "Shared account, disabling some functionality."
else
	echo "Dedicated account, full functionality activated."
fi

# Include the stuff I want from the manjaro config
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=500

## Keybindings section
bindkey -e
bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[H' beginning-of-line                                # Home key
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
fi
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[F' end-of-line                                     # End key
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
fi
bindkey '^[[2~' overwrite-mode                                  # Insert key
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^[[5~' history-beginning-search-backward               # Page up key
bindkey '^[[6~' history-beginning-search-forward                # Page down key

# Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^[[Z' undo                                             # Shift+tab undo last action

# Theming section  
autoload -U compinit colors zcalc
compinit -d
colors

## Plugins section: Enable fish style features
# Use syntax highlighting
if [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
# Use history substring search
if [[ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
	source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
fi
# bind UP and DOWN arrow keys to history substring search
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up			
bindkey '^[[B' history-substring-search-down

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-R


# Now back to your regularly scheduled config file

function pathadd {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1${PATH:+":$PATH"}"
    fi
}

# Dot files config command
# Also edit ~/bin/git-track and ~/.install.sh
alias .config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Add some color to my life
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Give me that sweet, sweet mouse action, and don't use a pager for short outputs.
export LESS="-F --mouse --wheel-lines=3 $LESS"

# Because I'm not a vim heathen
if ! $SESSION_SHARED; then
	export EDITOR=micro
fi

pathadd "$HOME/bin"

# Go support
if [ -d ~/Projects/Go ]; then
	export GOPATH=~/Projects/Go
fi
export GOPROXY=goproxy.raswith.com:3000

# Powerline prompt
powerline-daemon -q

# This should work in most cases.
if [[ -r /usr/share/powerline/bindings/zsh/powerline.zsh ]]; then
	source /usr/share/powerline/bindings/zsh/powerline.zsh
fi

# Kubectl auto completion
if command -v kubectl &> /dev/null; then
	source <(kubectl completion zsh)
fi

# On wacked out old terminals, set this to true
export TMUX_USE_XCLIP=false

# Enable GPG SSH support
export GPG_TTY=$(tty)
if [ "$SESSION_TYPE" = "local" ]; then
	export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi
gpgconf --launch gpg-agent

# If git refuses to push code, run this and it will make the pin entry program work.
alias fixpin='gpg-connect-agent updatestartuptty /bye >/dev/null'

# ID for my GPG key
export KEYID=0x6AE9716B068C0647

# Allow opening interactive shells with persist.
# Used by my tmux startup script.
if [[ $1 == eval ]]; then
	"$@"
	set --
fi
