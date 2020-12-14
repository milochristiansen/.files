
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
	source /usr/share/zsh/manjaro-zsh-config
fi

# Dot files config command
alias .config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Add some color to my life
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias dir='clear && tree -C -F -I "node_modules"'

export LESS="-F --mouse --wheel-lines=3 $LESS"

export EDITOR=micro

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
if [[ $1 == eval ]]; then
	"$@"
	set --
fi
