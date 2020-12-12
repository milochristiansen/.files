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
		sudo $PACMD $2
		return $?
	fi
}

# Make sure git is installed
ensure_installed git git

# And ZSH
ensure_installed zsh zsh

# Micro editor
ensure_installed micro micro

# And powerline of course.
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
    echo "Backing up pre-existing dot files.";
    .config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
.config checkout
.config config status.showUntrackedFiles no
