#!/usr/bin/env bash
# =============================================================================
# Barbarous Dotfiles — CLI Tool Installer
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
pkg_install() {
  local pkgs=("$@")
  case "$PKG_FAMILY" in
    fedora) run "sudo dnf install -y ${pkgs[*]}" ;;
    debian) run "sudo apt-get install -y ${pkgs[*]}" ;;
    arch)   run "sudo pacman -S --noconfirm ${pkgs[*]}" ;;
    *)      warn "Unknown distro — skipping: ${pkgs[*]}" ;;
  esac
}

cargo_install() {
  local crate="$1"
  if command -v cargo-binstall &>/dev/null; then run "cargo binstall -y $crate"
  elif command -v cargo &>/dev/null; then run "cargo install $crate"
  else warn "cargo not found for $crate"; fi
}

# Smart installer that tries system package manager, then falls back to cargo
smart_install() {
  local cmd="$1"; local pkg_name="${2:-$1}"; local cargo_name="${3:-$pkg_name}"
  if command -v "$cmd" &>/dev/null; then
    ok "$cmd already installed"
    return
  fi
  info "Installing $cmd ..."
  
  if [[ "$PKG_FAMILY" == "unknown" ]]; then
    cargo_install "$cargo_name"
    return
  fi

  # For Debian, some rust tools are outdated or not in apt, so prefer cargo for some
  if [[ "$PKG_FAMILY" == "debian" && "$cargo_name" =~ ^(procs|yazi-fm|dust)$ ]]; then
    cargo_install "$cargo_name"
  else
    pkg_install "$pkg_name" || cargo_install "$cargo_name"
  fi
}

# ── Dependency: Build Tools ───────────────────────────────────────────────────
head "Build Tools"
if ! command -v cc &>/dev/null && ! command -v gcc &>/dev/null; then
  info "Installing build tools (C compiler required for some packages)..."
  case "$PKG_FAMILY" in
    debian) pkg_install build-essential ;;
    fedora) pkg_install gcc gcc-c++ make ;;
    arch)   pkg_install base-devel ;;
    *)      warn "Please install a C compiler manually" ;;
  esac
else
  ok "Build tools already installed"
fi

# ── Dependency: Rust ──────────────────────────────────────────────────────────
head "Rust Toolchain"
if ! command -v cargo &>/dev/null; then
  info "Installing Rust via rustup..."
  run "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path"
  run "source \"$HOME/.cargo/env\""
else
  ok "Rust/cargo already installed"
fi

if ! command -v cargo-binstall &>/dev/null; then
  info "Installing cargo-binstall..."
  run "curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash"
else
  ok "cargo-binstall already installed"
fi

# ── Core Shell Tools ──────────────────────────────────────────────────────────
head "Core Tools"
smart_install zsh
smart_install tmux
smart_install git
smart_install stow

if ! command -v starship &>/dev/null; then
  info "Installing starship..."
  run "curl -sS https://starship.rs/install.sh | sh -s -- -y"
else
  ok "starship already installed"
fi

# ── Modern CLI Replacements ───────────────────────────────────────────────────
head "Modern CLI Replacements"
smart_install rg ripgrep ripgrep
smart_install delta git-delta git-delta
smart_install dust du-dust du-dust
smart_install procs procs procs
smart_install bat bat bat
smart_install eza eza eza
smart_install fd fd-find fd-find
smart_install zoxide zoxide zoxide
smart_install tldr tealdeer tealdeer

# ── Fuzzy Finder ─────────────────────────────────────────────────────────────
head "Fuzzy Finder"
if ! command -v fzf &>/dev/null; then
  if [[ "$PKG_FAMILY" == "unknown" ]]; then
    run "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --no-bash --no-fish --no-zsh --no-update-rc"
  else
    pkg_install fzf
  fi
else
  ok "fzf already installed"
fi

# ── Workflow Tools ────────────────────────────────────────────────────────────
head "Workflow Tools"
smart_install yazi yazi yazi-fm
smart_install lazygit lazygit lazygit
smart_install nvim neovim neovim

if ! command -v atuin &>/dev/null; then
  info "Installing atuin..."
  run "curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh"
else
  ok "atuin already installed"
fi

smart_install btop btop btop

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  info "Installing tmux plugin manager (tpm)..."
  run "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
else
  ok "tpm already installed"
fi

if ! command -v mise &>/dev/null; then
  info "Installing mise..."
  run "curl https://mise.run | sh"
else
  ok "mise already installed"
fi

smart_install topgrade topgrade topgrade


# ── Zsh Framework & Plugins ───────────────────────────────────────────────────
head "Zim Framework"
if [[ ! -d "$HOME/.zim" ]]; then
  info "Installing Zim framework..."
  run "curl -fsSL https://raw.githubusercontent.com/zimfw/zimfw/master/zimfw.zsh -o \"\${ZDOTDIR:-\$HOME}/.zim/zimfw.zsh\""
  run "zsh \"\${ZDOTDIR:-\$HOME}/.zim/zimfw.zsh\" install"
else
  ok "Zim already installed"
fi

# ── GNU Stow & Deploy ─────────────────────────────────────────────────────────
head "GNU Stow — Deploy Configs"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
info "Stowing all packages from $DOTFILES_DIR ..."

for pkg in atuin bash btop fonts fzf git lazygit mise nvim procs ripgrep shells starship tealdeer tmux topgrade yazi zsh; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    run "stow --dir=\"$DOTFILES_DIR\" --target=\"$HOME\" --restow \"$pkg\""
    ok "stowed: $pkg"
  fi
done

# ── Post-install ──────────────────────────────────────────────────────────────
head "Post-install"
if command -v tldr &>/dev/null; then run "tldr --update"; fi
if command -v yazi &>/dev/null && command -v ya &>/dev/null; then run "ya pack -i"; fi

echo -e "\n${GREEN}${BOLD}✔ Barbarous CLI environment installed and configured.${RESET}\n"
