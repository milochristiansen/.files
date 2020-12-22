
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
	source /usr/share/zsh/manjaro-zsh-config
fi

function pathadd {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1${PATH:+":$PATH"}"
    fi
}

export SESSION_TYPE="local"
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	SESSION_TYPE="remote/ssh"
else
	case $(ps -o comm= -p $PPID) in
		sshd|*/sshd) SESSION_TYPE=remote/ssh;;
	esac
fi

# Dot files config command
# Also edit ~/bin/git-track and ~/.install.sh
alias .config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Add some color to my life
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# TODO: Erite my own replacement for tree with better filtering.
# export TREE_FILTERS="node_modules|.git"
# alias dir='clear && tree -C -F -I "$TREE_FILTERS"'
alias dir='go run ~/Projects/tree.go $(tput cols)'

# Give me that sweet, sweet mouse action, and don't use a pager for short outputs.
export LESS="-F --mouse --wheel-lines=3 $LESS"

# Because I'm not a vim heathen
export EDITOR=micro

pathadd "$HOME/bin"

# Go support
if [ -d ~/Projects/Go ]; then
	export GOPATH=~/Projects/Go
fi

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
if [ $1 = eval ]; then
	"$@"
	set --
fi
