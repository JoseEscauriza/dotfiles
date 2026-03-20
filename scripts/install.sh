#!/bin/bash

ROOT_PATH=$(pwd -P)

set -e

# System update
sudo pacman -Syu --noconfirm

# Install official Packages
sudo pacman -S --needed --noconfirm - <packages/package_list.txt
# Install yay if missing
if ! command -v yay &>/dev/null; then
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  cd ..
fi

# Install AUR Packages
yay -S --needed --noconfirm - <packages/aur_list.txt

# Install oh-my-zsh
cd ~
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cd -

# Install waybar-module-pomodoro
cd ~
git clone https://github.com/Andeskjerf/waybar-module-pomodoro.git
cd waybar-module-pomodoro
cargo build --release
cp target/release/waybar-module-pomodoro /usr/bin/
cd ROOT_PATH

# Install awww-daemon
cd ~
git clone https://codeberg.org/LGFae/awww.git
cd awww
cargo build --release
cp target/release/awww /usr/bin/
cp target/release/awww-daemon /usr/bin/
cd ROOT_PATH
