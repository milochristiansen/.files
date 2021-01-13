#!/usr/bin/env bash

# Are we in a shared acount?
export SESSION_SHARED=false
if [ "$USER" = "milo" ]; then
	SESSION_SHARED=true
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
		sudo $PACMD $@
		return $?
	fi
}

# Make sure git is installed
ensure_installed git

# And ZSH
ensure_installed zsh

# Micro editor
ensure_installed micro
micro -plugin install go
micro -plugin install quoter
micro -plugin install manipulator
micro -plugin install aspell

ensure_installed aspell aspell-en

# tmux
ensure_installed tmux

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
git clone --bare git@github.com:milochristiansen/.files.git $HOME/.cfg
mkdir -p .config-backup
.config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
else
    echo "Backing up pre-existing files.";
    .config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs /bin/bash -c 'mkdir -p `dirname ".config-backup/$@"`; mv "$@" ".config-backup/$@"' ''
fi;
.config checkout

go build -o ~/Projects/tree.bin ~/Projects/tree.go

if ! $SESSION_SHARED; then
	sudo usermod --shell /bin/zsh $USER
fi

echo "Log out and back in to complete setup."
