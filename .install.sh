#!/usr/bin/env bash

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

# Tree (used by my tmux config)
ensure_installed tree

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

ssh -T git@github.com
if [ $? = 255 ]; then
	echo "Could not authenticate with github."
	exit 2 
fi

function backup {
	mkdir -p `dirname "$1"`
	mv "$1" ".config-backup/$1"
}

# Pull the files
git clone --bare git@github.com:milochristiansen/.files.git $HOME/.cfg
mkdir -p .config-backup
.config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
else
    echo "Backing up pre-existing files.";
    .config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} backup {}
fi;
.config checkout

sudo usermod --shell /bin/zsh $USER

exec zsh
