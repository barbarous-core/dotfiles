#!/usr/bin/env bash
# =============================================================================
# Barbarous Dotfiles — GUI Tool Installer
# =============================================================================

set -euo pipefail

# Ensure common local bin directories are in PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# ── Colors & Logging ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { echo -e "${GREEN}✔${RESET}  $*"; }
info() { echo -e "${CYAN}→${RESET}  $*"; }
warn() { echo -e "${YELLOW}⚠${RESET}  $*"; }
head() { echo -e "\n${BOLD}${CYAN}══ $* ══${RESET}"; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

run() {
  if $DRY_RUN; then
    echo -e "  ${YELLOW}[dry-run]${RESET} $*"
  else
    eval "$*"
  fi
}

# ── Distro Detection ──────────────────────────────────────────────────────────
if [[ -f /etc/os-release ]]; then
  source /etc/os-release
  DISTRO_ID="${ID:-unknown}"
else
  DISTRO_ID="unknown"
fi

info "Detected distro: ${BOLD}${DISTRO_ID}${RESET}"

# ── Package Installation Helpers ─────────────────────────────────────────────
pkg_install() {
  local pkgs=("$@")
  case "$DISTRO_ID" in
    fedora) run "sudo dnf install -y ${pkgs[*]}" ;;
    ubuntu|debian) run "sudo apt-get install -y ${pkgs[*]}" ;;
    arch) run "sudo pacman -S --noconfirm ${pkgs[*]}" ;;
    *) warn "Unknown distro — skipping: ${pkgs[*]}" ;;
  esac
}

group_install() {
  local group="$1"
  case "$DISTRO_ID" in
    fedora) run "sudo dnf groupinstall -y \"$group\"" ;;
    *) warn "Group install not supported for this distro: $group" ;;
  esac
}

# ── GUI Applications ─────────────────────────────────────────────────────────

head "Desktop Environments & Window Managers"
group_install "Xfce Desktop"
group_install "LXQt Desktop"
pkg_install sway

head "Terminal & Utilities"
pkg_install kitty rofi kvantum qt5ct qt6ct

head "Web Browsers"
# Firefox
pkg_install firefox

# Brave (Fedora specific)
if [[ "$DISTRO_ID" == "fedora" ]]; then
  info "Configuring Brave Browser repo..."
  run "sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo"
  run "sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc"
  pkg_install brave-browser
fi

# Google Chrome (Fedora specific)
if [[ "$DISTRO_ID" == "fedora" ]]; then
  info "Configuring Google Chrome repo..."
  run "sudo dnf config-manager --set-enabled google-chrome"
  pkg_install google-chrome-stable
fi

head "Editors & IDEs"
# VS Code (Fedora specific)
if [[ "$DISTRO_ID" == "fedora" ]]; then
  info "Configuring VS Code repo..."
  run "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
  run "sudo sh -c 'echo -e \"[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\" > /etc/yum.repos.d/vscode.repo'"
  pkg_install code
fi

# Zed Editor
if ! command -v zed &>/dev/null; then
  info "Installing Zed Editor..."
  run "curl -f https://zed.dev/install.sh | sh"
else
  ok "Zed Editor already installed"
fi

head "Productivity"
# Obsidian
if ! command -v obsidian &>/dev/null && ! flatpak list | grep -q "Obsidian"; then
  info "Installing Obsidian via Flatpak..."
  run "flatpak install -y flathub md.obsidian.Obsidian"
else
  ok "Obsidian already installed"
fi

# ── GUI Themes ──────────────────────────────────────────────────────────────
head "GUI Themes"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$DOTFILES_DIR/scripts/install_gui_themes.sh" ]]; then
  run "$DOTFILES_DIR/scripts/install_gui_themes.sh"
fi

# ── GNU Stow — Deploy Configs ─────────────────────────────────────────────────
head "GNU Stow — Deploy GUI Configs"
info "Stowing GUI packages..."
for pkg in gtk kitty rofi gui; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    run "stow --dir=\"$DOTFILES_DIR\" --target=\"$HOME\" --restow \"$pkg\""
    ok "stowed: $pkg"
  fi
done

echo -e "\n${GREEN}${BOLD}✔ Barbarous GUI environment installed and configured.${RESET}\n"
