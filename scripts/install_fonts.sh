#!/usr/bin/env bash
# =============================================================================
# Font Installer (Nerd Fonts & Arabic) managed via Stow
# =============================================================================

set -euo pipefail

FONTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/fonts/.local/share/fonts"
mkdir -p "$FONTS_DIR"

echo "Downloading JetBrainsMono Nerd Font..."
wget -q --show-progress -O /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
mkdir -p "$FONTS_DIR/JetBrainsMono"
unzip -qo /tmp/JetBrainsMono.zip -d "$FONTS_DIR/JetBrainsMono"

echo "Downloading Vazirmatn Arabic Font..."
wget -q --show-progress -O /tmp/vazirmatn.zip "https://github.com/rastikerdar/vazirmatn/releases/download/v33.003/vazirmatn-v33.003.zip"
mkdir -p "$FONTS_DIR/Vazirmatn"
unzip -qo /tmp/vazirmatn.zip -d "$FONTS_DIR/Vazirmatn"

echo "Downloading Kawkab Mono Arabic Font..."
wget -q --show-progress -O /tmp/kawkab-mono.zip "https://github.com/aiaf/kawkab-mono/releases/latest/download/kawkab-mono-0.501.zip" || wget -q --show-progress -O /tmp/kawkab-mono.zip "https://github.com/aiaf/kawkab-mono/archive/refs/heads/master.zip"
mkdir -p "$FONTS_DIR/KawkabMono"
unzip -qo /tmp/kawkab-mono.zip -d "$FONTS_DIR/KawkabMono"
# Move the font files to the main directory to ensure they are picked up, and clean up
find "$FONTS_DIR/KawkabMono" -name "*.ttf" -exec mv {} "$FONTS_DIR/KawkabMono/" \; 2>/dev/null || true

echo "Fonts downloaded to $FONTS_DIR"
echo "To manage with stow, run: cd ~/dotfiles && stow fonts"
echo "Updating font cache..."
fc-cache -fv | grep -i "succeeded" || echo "Done."
