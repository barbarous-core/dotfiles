#!/usr/bin/env bash
# =============================================================================
# Barbarous Dotfiles — CLI Tool Uninstaller
# =============================================================================

set -euo pipefail

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
  # shellcheck disable=SC1091
  source /etc/os-release
  DISTRO_ID="${ID:-unknown}"
  DISTRO_ID_LIKE="${ID_LIKE:-}"
else
  DISTRO_ID="unknown"
  DISTRO_ID_LIKE=""
fi

case "$DISTRO_ID" in
  fedora|rhel|centos|rocky|almalinux) PKG_FAMILY="fedora" ;;
  ubuntu|debian|linuxmint|pop)        PKG_FAMILY="debian" ;;
  arch|manjaro|endeavouros|garuda)    PKG_FAMILY="arch" ;;
  *)
    if [[ "$DISTRO_ID_LIKE" == *"fedora"* || "$DISTRO_ID_LIKE" == *"rhel"* ]]; then PKG_FAMILY="fedora"
    elif [[ "$DISTRO_ID_LIKE" == *"debian"* || "$DISTRO_ID_LIKE" == *"ubuntu"* ]]; then PKG_FAMILY="debian"
    elif [[ "$DISTRO_ID_LIKE" == *"arch"* ]]; then PKG_FAMILY="arch"
    else PKG_FAMILY="unknown"; fi ;;
esac

info "Detected distro family: ${BOLD}${PKG_FAMILY}${RESET} (${DISTRO_ID})"

# ── Package Managers ──────────────────────────────────────────────────────────
is_installed() {
  local pkg="$1"
  case "$PKG_FAMILY" in
    fedora) rpm -q "$pkg" &>/dev/null ;;
    debian) dpkg -s "$pkg" 2>/dev/null | grep -q "^Status: install ok installed" ;;
    arch)   pacman -Q "$pkg" &>/dev/null ;;
    *)      return 1 ;;
  esac
}

pkg_remove() {
  local pkgs=("$@")
  local to_remove=()

  for pkg in "${pkgs[@]}"; do
    if is_installed "$pkg"; then
      to_remove+=("$pkg")
    else
      ok "$pkg is not installed via package manager"
    fi
  done

  if [[ ${#to_remove[@]} -eq 0 ]]; then
    return 0
  fi

  case "$PKG_FAMILY" in
    fedora) run "sudo dnf remove -y ${to_remove[*]} && sudo dnf autoremove -y" ;;
    debian) run "sudo apt-get purge --auto-remove -y ${to_remove[*]}" ;;
    arch)   run "sudo pacman -Rns --noconfirm ${to_remove[*]}" ;;
    *)      warn "Unknown distro — skipping: ${to_remove[*]}" ;;
  esac
}

cargo_uninstall() {
  local crate="$1"
  if command -v cargo &>/dev/null; then
    if cargo install --list | grep -q "^$crate v"; then
      run "cargo uninstall $crate"
    fi
  fi
}

smart_uninstall() {
  local cmd="$1"; local pkg_name="${2:-$1}"; local cargo_name="${3:-$pkg_name}"
  info "Uninstalling $cmd ..."
  
  # Try both system package manager and cargo to ensure complete removal
  if [[ "$PKG_FAMILY" != "unknown" ]]; then
    pkg_remove "$pkg_name"
  fi
  cargo_uninstall "$cargo_name"
}

# ── Remove GNU Stow Configs ───────────────────────────────────────────────────
head "GNU Stow — Remove Configs"
if command -v stow &>/dev/null; then
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

  for pkg in atuin bash btop fonts fzf git lazygit mise nvim procs ripgrep shells starship tealdeer tmux topgrade yazi zsh; do
    if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
      run "stow --dir=\"$DOTFILES_DIR\" --target=\"$HOME\" --delete \"$pkg\""
      ok "unstowed: $pkg"
    fi
  done
else
  warn "stow command not found — skipping configuration removal"
fi

# ── Core Shell Tools ──────────────────────────────────────────────────────────
head "Core Tools"
smart_uninstall zsh
smart_uninstall tmux
smart_uninstall git
smart_uninstall stow

# ── Modern CLI Replacements ───────────────────────────────────────────────────
head "Modern CLI Replacements"
smart_uninstall rg ripgrep ripgrep
smart_uninstall delta git-delta git-delta
smart_uninstall dust du-dust du-dust
smart_uninstall procs procs procs
smart_uninstall bat bat bat
smart_uninstall eza eza eza
smart_uninstall fd fd-find fd-find
smart_uninstall zoxide zoxide zoxide
smart_uninstall tldr tealdeer tealdeer

# ── Fuzzy Finder ─────────────────────────────────────────────────────────────
head "Fuzzy Finder"
if [[ "$PKG_FAMILY" == "unknown" && -d "$HOME/.fzf" ]]; then
  info "Removing fzf from ~/.fzf..."
  run "rm -rf ~/.fzf"
else
  pkg_remove fzf
fi

# ── Workflow Tools ────────────────────────────────────────────────────────────
head "Workflow Tools"
smart_uninstall yazi yazi yazi-fm
smart_uninstall lazygit lazygit lazygit
smart_uninstall nvim neovim neovim
smart_uninstall btop btop btop
smart_uninstall topgrade topgrade topgrade

# Script-installed tools
if command -v starship &>/dev/null; then
  info "Removing starship..."
  run "sudo rm -f /usr/local/bin/starship"
fi

if [[ -d "$HOME/.local/share/atuin" || -d "$HOME/.atuin" ]]; then
  info "Removing atuin..."
  run "rm -rf ~/.local/share/atuin ~/.atuin"
fi

if command -v atuin &>/dev/null; then
    pkg_remove atuin
fi

if command -v mise &>/dev/null; then
  info "Removing mise..."
  run "rm -f ~/.local/bin/mise ~/.config/mise"
fi

if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
  info "Removing tmux plugin manager (tpm)..."
  run "rm -rf ~/.tmux/plugins/tpm"
fi

# ── Zsh Framework & Plugins ───────────────────────────────────────────────────
head "Zsh & Zim Cleanup"
info "Removing Zim framework and Zsh artifacts..."
run "rm -rf ~/.zim ~/.zsh ~/.zcompdump* ~/.zimrc"

# ── Shell Config Cleanup ──────────────────────────────────────────────────────
head "Shell Config Cleanup"
info "Cleaning up shell configuration files..."
for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.zshenv" "$HOME/.bash_profile"; do
  if [[ -f "$rc" ]]; then
    info "Cleaning $rc ..."
    # Remove lines added by the installer tools
    sed -i '/.cargo\/env/d' "$rc"
    sed -i '/.atuin\/bin\/env/d' "$rc"
    sed -i '/atuin init/d' "$rc"
    sed -i '/starship init/d' "$rc"
    sed -i '/zoxide init/d' "$rc"
    sed -i '/mise activate/d' "$rc"
    sed -i '/zimfw/d' "$rc"
  fi
done

# ── Build Tools ───────────────────────────────────────────────────────────────
head "Build Tools"
info "Removing build tools..."
case "$PKG_FAMILY" in
  debian) pkg_remove build-essential ;;
  fedora) pkg_remove gcc gcc-c++ make ;;
  arch)   pkg_remove base-devel ;;
esac

# ── Rust Toolchain ────────────────────────────────────────────────────────────
head "Rust Toolchain"
if command -v rustup &>/dev/null; then
  info "Removing Rust via rustup..."
  run "rustup self uninstall -y"
fi

echo -e "\n${GREEN}${BOLD}✔ Barbarous CLI environment uninstalled.${RESET}\n"

# ── Logout ────────────────────────────────────────────────────────────────────
if ! $DRY_RUN; then
  head "Logout"
  info "Logging out in 3 seconds to apply changes..."
  sleep 3
  run "pkill -KILL -u \"\$USER\""
fi
