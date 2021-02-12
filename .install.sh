#!/usr/bin/env bash

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

# This script should support at least Debian-based and Arch-based distros.
PACMD=
PACMAN=
if command -v apt-get; then
	PACMD='apt-get install -qq'
	PACMAN="apt"
fi
if command -v pacman; then
	PACMD='pacman -Syu'
	PACMAN="pacman"
fi

echo $PACMD
if ! [ -n "$PACMD" ]; then
	echo "Could not detect package manager."
	exit 1
fi

function ensure_installed {
	if ! command -v $1; then
		if [ "$2" = "" ]; then
			sudo $PACMD $1
			return $?
		fi
		
		sudo $PACMD ${@: 2}
		return $?
	fi
}

# Make sure git is installed
ensure_installed git

# And ZSH
ensure_installed zsh

# Micro editor
if ! command -v micro; then
	pushd ~/bin
	curl https://getmic.ro | bash
	popd

	~/bin/micro -plugin install go
	~/bin/micro -plugin install quoter
	~/bin/micro -plugin install manipulator
	~/bin/micro -plugin install aspell
fi

ensure_installed aspell aspell aspell-en

if [ "SESSION_TYPE" = "local" ]; then
	# go
	ensure_installed go golang-go
	ensure_installed go go
	
	pushd ~/Projects/Modules/tree
	go build -o ~/bin/dir
	popd
fi

# tmux
if [ "$SESSION_TYPE" = "local" ]; then
	ensure_installed tmux
fi

# GPG
if [ "$PACMAN" = "pacman" ]; then
	sudo pacman -Syu gnupg pcsclite ccid
elif [ "$PACMAN" = "apt" ]; then
	sudo apt -y install wget gnupg2 gnupg-agent dirmngr cryptsetup scdaemon pcscd
fi

# Finally powerline, of course.
sudo $PACMD powerline

# Set up the ".config" command
function .config {
	/usr/bin/git --git-dir="$HOME/.cfg/" --work-tree="$HOME" $@
}

# Pull the files
git clone --bare git@github.com:milochristiansen/.files.git "$HOME/.cfg"

# Now setup sparse checkout if we are not on a dedicated, local account.
if [ "$SESSION_TYPE" != "local" ] || $SESSION_SHARED; then
	.config show HEAD:.gitsparse > "$HOME/.gitsparse"
	ln -s -T "$HOME/.gitsparse" "$HOME/.cfg/info/sparse-checkout"
	.config sparse-checkout init
fi

mkdir -p .config-backup
.config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
else
    echo "Backing up pre-existing files.";
    .config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -n 1 /bin/bash -c 'mkdir -p `dirname ".config-backup/$@"`; mv "$@" ".config-backup/$@"'
fi;
.config checkout

if ! $SESSION_SHARED; then
	sudo usermod --shell /bin/zsh $USER
fi

echo "Log out and back in to complete setup."
