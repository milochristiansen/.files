#!/usr/bin/env bash

# This script should support at least Debian-based and Arch-based distros.
PACMD=
if ! command -v apt-get; then
	PACMD='apt-get install'
fi
if ! command -v pacman; then
	PACMD='pacman -S'
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
    .config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
.config checkout
.config config status.showUntrackedFiles no
