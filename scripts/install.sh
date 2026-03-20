#!/bin/bash

ROOT_PATH=$(pwd -P)

set -ex

# System update
sudo pacman -Syu --noconfirm

# Install official Packages
while read -r pkg; do
  sudo pacman -S --needed --noconfirm - <"$pkg"
done <package_list.txt

# Install yay if missing
if ! command -v yay &>/dev/null; then
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
fi

# Install AUR Packages
while read -r pkg; do
  yay -S --needed --noconfirm - <"$pkg"
done <aur_list.txt

# Install oh-my-zsh
cd ~
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cd -

sudo pacman -S --needed rust

# Install waybar-module-pomodoro
cd ~
git clone https://github.com/Andeskjerf/waybar-module-pomodoro.git
cd waybar-module-pomodoro
cargo build --release
sudo cp target/release/waybar-module-pomodoro /usr/bin/
cd "$ROOT_PATH"

# Install awww-daemon
cd ~
git clone https://codeberg.org/LGFae/awww.git
cd awww
cargo build --release
sudo cp target/release/awww /usr/bin/
sudo cp target/release/awww-daemon /usr/bin/
cd "$ROOT_PATH"
