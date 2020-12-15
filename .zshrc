
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
	source /usr/share/zsh/manjaro-zsh-config
fi

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

# TODO: Erite my own replacement for tree with better filtering.
export TREE_FILTERS="node_modules|.git"
alias dir='clear && tree -C -F -I "$TREE_FILTERS"'

# Give me that sweet, sweet mouse action, and don't use a pager for short outputs.
export LESS="-F --mouse --wheel-lines=3 $LESS"

# Because I'm not a heathen
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

# Allow opening interactive shells with persist.
# Used by my tmux startup script.
if [[ $1 == eval ]]; then
	"$@"
	set --
fi
