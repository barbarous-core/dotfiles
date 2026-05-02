#!/usr/bin/env bash
# =============================================================================
# Barbarous Dotfiles — CLI Tool Installer
# =============================================================================
# Detects distro and installs all tools that are configured in this dotfiles
# repo. Falls back to cargo/binary install when a package is unavailable.
#
# Usage:
#   ./scripts/install.sh          # install everything
#   ./scripts/install.sh --dry-run  # show what would be installed
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { echo -e "${GREEN}✔${RESET}  $*"; }
info() { echo -e "${CYAN}→${RESET}  $*"; }
warn() { echo -e "${YELLOW}⚠${RESET}  $*"; }
fail() { echo -e "${RED}✘${RESET}  $*"; }
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
detect_distro() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_ID_LIKE="${ID_LIKE:-}"
  else
    DISTRO_ID="unknown"
    DISTRO_ID_LIKE=""
  fi

  # Normalise to a family
  case "$DISTRO_ID" in
    fedora|rhel|centos|rocky|almalinux)
      PKG_FAMILY="fedora" ;;
    ubuntu|debian|linuxmint|pop)
      PKG_FAMILY="debian" ;;
    arch|manjaro|endeavouros|garuda)
      PKG_FAMILY="arch" ;;
    *)
      # Try ID_LIKE as fallback
      if [[ "$DISTRO_ID_LIKE" == *"fedora"* || "$DISTRO_ID_LIKE" == *"rhel"* ]]; then
        PKG_FAMILY="fedora"
      elif [[ "$DISTRO_ID_LIKE" == *"debian"* || "$DISTRO_ID_LIKE" == *"ubuntu"* ]]; then
        PKG_FAMILY="debian"
      elif [[ "$DISTRO_ID_LIKE" == *"arch"* ]]; then
        PKG_FAMILY="arch"
      else
        PKG_FAMILY="unknown"
      fi ;;
  esac

  echo "$PKG_FAMILY"
}

PKG_FAMILY=$(detect_distro)
info "Detected distro family: ${BOLD}${PKG_FAMILY}${RESET} (${DISTRO_ID})"

# ── Package Manager Wrappers ──────────────────────────────────────────────────
pkg_install() {
  local pkgs=("$@")
  case "$PKG_FAMILY" in
    fedora)  run "sudo dnf install -y ${pkgs[*]}" ;;
    debian)  run "sudo apt-get install -y ${pkgs[*]}" ;;
    arch)    run "sudo pacman -S --noconfirm ${pkgs[*]}" ;;
    *)       warn "Unknown distro — skipping package install for: ${pkgs[*]}" ;;
  esac
}

# Install a tool only if it's not already on PATH
ensure() {
  local cmd="$1"; shift
  if command -v "$cmd" &>/dev/null; then
    ok "$cmd already installed ($(command -v "$cmd"))"
  else
    info "Installing $cmd ..."
    "$@"
  fi
}

# Cargo install (uses cargo-binstall if available for speed)
cargo_install() {
  local crate="$1"
  if command -v cargo-binstall &>/dev/null; then
    run "cargo binstall -y $crate"
  elif command -v cargo &>/dev/null; then
    run "cargo install $crate"
  else
    warn "cargo not found — cannot install $crate. Install Rust first: https://rustup.rs"
  fi
}

# ── Dependency: Rust / Cargo ──────────────────────────────────────────────────
head "Rust Toolchain"
if ! command -v cargo &>/dev/null; then
  info "Installing Rust via rustup..."
  run "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path"
  # shellcheck disable=SC1090
  run "source \"$HOME/.cargo/env\""
else
  ok "Rust/cargo already installed"
fi

# ── Core Shell Tools ──────────────────────────────────────────────────────────
head "Core Shell Tools"

# zsh — configured in dotfiles/zsh
ensure zsh pkg_install zsh

# tmux — configured in dotfiles/tmux
ensure tmux pkg_install tmux

# git — configured in dotfiles/git
ensure git pkg_install git

# starship — configured in dotfiles/starship
ensure starship \
  bash -c 'curl -sS https://starship.rs/install.sh | sh -s -- -y'

# ── Modern CLI Replacements ───────────────────────────────────────────────────
head "Modern CLI Replacements (The Big 4 + extras)"

# ripgrep (rg) — configured in dotfiles/ripgrep
ensure rg \
  case "$PKG_FAMILY" in
    fedora)  pkg_install ripgrep ;;
    debian)  pkg_install ripgrep ;;
    arch)    pkg_install ripgrep ;;
    *)       cargo_install ripgrep ;;
  esac

# delta — configured via git & lazygit
ensure delta \
  case "$PKG_FAMILY" in
    fedora)  pkg_install git-delta ;;
    debian)  pkg_install git-delta ;;
    arch)    pkg_install git-delta ;;
    *)       cargo_install git-delta ;;
  esac

# dust (du replacement) — alias du=dust
ensure dust \
  case "$PKG_FAMILY" in
    fedora)  pkg_install dust ;;
    debian)  pkg_install du-dust ;;
    arch)    pkg_install dust ;;
    *)       cargo_install du-dust ;;
  esac

# procs (ps replacement) — configured in dotfiles/procs
ensure procs \
  case "$PKG_FAMILY" in
    fedora)  pkg_install procs ;;
    debian)  cargo_install procs ;;
    arch)    pkg_install procs ;;
    *)       cargo_install procs ;;
  esac

# bat (cat replacement) — alias cat=bat
ensure bat \
  case "$PKG_FAMILY" in
    fedora)  pkg_install bat ;;
    debian)  pkg_install bat ;;
    arch)    pkg_install bat ;;
    *)       cargo_install bat ;;
  esac

# eza (ls replacement) — alias ls=eza
ensure eza \
  case "$PKG_FAMILY" in
    fedora)  pkg_install eza ;;
    debian)  pkg_install eza ;;
    arch)    pkg_install eza ;;
    *)       cargo_install eza ;;
  esac

# fd (find replacement) — used by fzf
ensure fd \
  case "$PKG_FAMILY" in
    fedora)  pkg_install fd-find ;;
    debian)  pkg_install fd-find ;;
    arch)    pkg_install fd ;;
    *)       cargo_install fd-find ;;
  esac

# zoxide (smarter cd) — configured in dotfiles/shells/init
ensure zoxide \
  case "$PKG_FAMILY" in
    fedora)  pkg_install zoxide ;;
    debian)  pkg_install zoxide ;;
    arch)    pkg_install zoxide ;;
    *)       cargo_install zoxide ;;
  esac

# tealdeer (tldr) — configured in dotfiles/tealdeer
ensure tldr \
  case "$PKG_FAMILY" in
    fedora)  cargo_install tealdeer ;;      # not in Fedora repos yet
    debian)  pkg_install tealdeer ;;
    arch)    pkg_install tealdeer ;;
    *)       cargo_install tealdeer ;;
  esac

# ── Fuzzy Finder ─────────────────────────────────────────────────────────────
head "Fuzzy Finder"

# fzf — configured in dotfiles/fzf
ensure fzf \
  case "$PKG_FAMILY" in
    fedora)  pkg_install fzf ;;
    debian)  pkg_install fzf ;;
    arch)    pkg_install fzf ;;
    *)       run "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --no-bash --no-fish --no-zsh --no-update-rc" ;;
  esac

# ── Workflow Tools ────────────────────────────────────────────────────────────
head "Workflow Tools"

# yazi — configured in dotfiles/yazi
ensure yazi \
  case "$PKG_FAMILY" in
    fedora)  pkg_install yazi ;;
    debian)  cargo_install yazi-fm ;;
    arch)    pkg_install yazi ;;
    *)       cargo_install yazi-fm ;;
  esac

# lazygit — configured in dotfiles/lazygit
ensure lazygit \
  case "$PKG_FAMILY" in
    fedora)
      run "LAZYGIT_VERSION=\$(curl -s 'https://api.github.com/repos/jesseduffield/lazygit/releases/latest' | grep -o '\"tag_name\": \"v[^\"]*' | cut -d'\"' -f4 | sed 's/v//')"
      run "curl -Lo lazygit.tar.gz \"https://github.com/jesseduffield/lazygit/releases/download/v\${LAZYGIT_VERSION}/lazygit_\${LAZYGIT_VERSION}_Linux_x86_64.tar.gz\""
      run "tar xf lazygit.tar.gz lazygit"
      run "sudo install lazygit -D -t /usr/local/bin/"
      run "rm -f lazygit lazygit.tar.gz"
      ;;
    debian)  pkg_install lazygit ;;
    arch)    pkg_install lazygit ;;
    *)
      warn "lazygit: download manually from https://github.com/jesseduffield/lazygit/releases"
      ;;
  esac

# atuin — configured in dotfiles/atuin
ensure atuin \
  case "$PKG_FAMILY" in
    fedora|debian|arch)
      run "curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh"
      ;;
    *)
      cargo_install atuin
      ;;
  esac

# btop — configured in dotfiles/btop
ensure btop \
  case "$PKG_FAMILY" in
    fedora)  pkg_install btop ;;
    debian)  pkg_install btop ;;
    arch)    pkg_install btop ;;
    *)       warn "btop: install from https://github.com/aristocratos/btop/releases" ;;
  esac

# tmux plugin manager (tpm) — used by dotfiles/tmux
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  info "Installing tmux plugin manager (tpm)..."
  run "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
else
  ok "tpm already installed"
fi

# mise — configured in dotfiles/mise
ensure mise \
  run "curl https://mise.run | sh"

# topgrade — configured in dotfiles/topgrade
ensure topgrade \
  cargo_install topgrade

# cargo-binstall — used by mise to speed up cargo installs
ensure cargo-binstall \
  run "curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-releases.sh | bash"

# ── Zsh Framework & Plugins ───────────────────────────────────────────────────
head "Zsh — Zim Framework"

if [[ ! -d "$HOME/.zim" ]]; then
  info "Installing Zim framework..."
  run "curl -fsSL https://raw.githubusercontent.com/zimfw/zimfw/master/zimfw.zsh -o \"\${ZDOTDIR:-\$HOME}/.zim/zimfw.zsh\""
  run "zsh \"\${ZDOTDIR:-\$HOME}/.zim/zimfw.zsh\" install"
else
  ok "Zim already installed"
fi

# ── GNU Stow & Deploy ─────────────────────────────────────────────────────────
head "GNU Stow — Deploy Configs"

ensure stow pkg_install stow

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
info "Stowing all packages from $DOTFILES_DIR ..."

STOW_PKGS=(
  atuin
  bash
  btop
  fzf
  git
  lazygit
  mise
  nvim
  procs
  ripgrep
  shells
  starship
  tealdeer
  tmux
  topgrade
  yazi
  zsh
)

for pkg in "${STOW_PKGS[@]}"; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    run "stow --dir=\"$DOTFILES_DIR\" --target=\"$HOME\" --restow \"$pkg\""
    ok "stowed: $pkg"
  else
    warn "skipped (not found): $pkg"
  fi
done

# ── Post-install ──────────────────────────────────────────────────────────────
head "Post-install"

# Seed tealdeer cache
if command -v tldr &>/dev/null; then
  info "Seeding tealdeer cache..."
  run "tldr --update"
fi

# Install yazi plugins
if command -v yazi &>/dev/null && command -v ya &>/dev/null; then
  info "Installing yazi plugins..."
  run "ya pack -i"
fi

echo -e "\n${GREEN}${BOLD}✔ Barbarous CLI environment installed and configured.${RESET}"
echo -e "  Restart your shell or run: ${CYAN}exec \$SHELL${RESET}\n"
