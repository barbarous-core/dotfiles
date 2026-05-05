#!/bin/bash

# Script to install Tokyo Night GTK and Icon themes

THEMES_DIR="$HOME/.themes"
ICONS_DIR="$HOME/.icons"

mkdir -p "$THEMES_DIR" "$ICONS_DIR"

echo "Downloading Tokyo Night GTK Theme..."
# Using Fausto-Korpsvart's theme as recommended in search
git clone https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git /tmp/Tokyonight-GTK
cp -r /tmp/Tokyonight-GTK/themes/Tokyonight-Dark "$THEMES_DIR/"

echo "Downloading Tokyo Night Icon Theme..."
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git /tmp/Tela-Icons
/tmp/Tela-Icons/install.sh -d "$ICONS_DIR" blue

echo "Downloading Tokyo Night Kvantum Theme..."
mkdir -p "$HOME/.config/Kvantum"
git clone https://github.com/Gis60/tokyo-night-kvantum.git /tmp/Kvantum-TokyoNight
cp -r /tmp/Kvantum-TokyoNight/TokyoNight "$HOME/.config/Kvantum/"
# Set Kvantum to use TokyoNight if kvantummanager is available
if command -v kvantummanager &>/dev/null; then
  kvantummanager --set TokyoNight
fi

echo "Cleanup..."
rm -rf /tmp/Tokyonight-GTK /tmp/Tela-Icons

echo "Themes installed successfully!"
