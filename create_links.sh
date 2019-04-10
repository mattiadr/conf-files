#!/bin/sh

curr_dir=$(pwd)

cln() {
	rm -rf "$2"
	ln -s "$curr_dir/$1" "$2"
}

#  | conf-files       | real file
cln awesome            ~/.config/awesome
cln cower              ~/.config/cower
cln git/.gitconfig     ~/.gitconfig
cln htop               ~/.config/htop
cln nano/nanorc        /etc/nanorc
cln pacman/mirrorlist  /etc/pacman.d/mirrorlist
cln pacman/pacman.conf /etc/pacman.conf
cln ranger             ~/.config/ranger
cln sublime-text-3     ~/.config/sublime-text-3
cln vlc                ~/.config/vlc
cln xorg/.xinitrc      ~/.xinitrc
cln xorg/.Xresources   ~/.Xresources
cln zsh/zshenv         /etc/zsh/zshenv
cln zsh/zshrc          /etc/zsh/zshrc
