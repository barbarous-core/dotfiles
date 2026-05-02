#!/usr/bin/env bash

# Yazi Configuration Switcher
# Usage: ./switch.sh [barbarous|codeopshq|linkarzu]

TARGET=$1
DOTFILES_DIR="$HOME/dotfiles"
YAZI_CONFIG_DIR="$DOTFILES_DIR/yazi/.config/yazi"

if [[ -z "$TARGET" ]]; then
    echo "Usage: ./switch.sh [barbarous|codeopshq|linkarzu]"
    exit 1
fi

if [[ ! -d "$YAZI_CONFIG_DIR/$TARGET" ]]; then
    echo "Error: Configuration '$TARGET' not found in $YAZI_CONFIG_DIR"
    exit 1
fi

echo "Switching Yazi configuration to: $TARGET"

# Remove current root files (but keep subdirectories)
find "$YAZI_CONFIG_DIR" -maxdepth 1 -type f -delete

# Copy new files to root
cp -r "$YAZI_CONFIG_DIR/$TARGET"/* "$YAZI_CONFIG_DIR/"

echo "Done! If you have already run 'stow yazi', the changes are active."
