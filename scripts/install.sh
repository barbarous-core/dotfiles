#!/usr/bin/env bash
# =============================================================================
# Barbarous Dotfiles — CLI Tool Installer
# =============================================================================

set -euo pipefail

if [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi

# Ensure common local bin directories are in PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.atuin/bin:$PATH"

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

pkg_install() {
  local pkgs=("$@")
  local missing=()

  for pkg in "${pkgs[@]}"; do
    if is_installed "$pkg"; then
      ok "$pkg already installed (pkg)"
    else
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    return 0
  fi

  case "$PKG_FAMILY" in
    fedora) run "sudo dnf install -y ${missing[*]}" ;;
    debian) run "sudo apt-get install -y ${missing[*]}" ;;
    arch)   run "sudo pacman -S --noconfirm ${missing[*]}" ;;
    *)      warn "Unknown distro — skipping: ${missing[*]}" ;;
  esac
}

fedora_copr() {
  local repo="$1"
  if [[ "$PKG_FAMILY" == "fedora" ]]; then
    info "Enabling Fedora COPR: $repo ..."
    run "sudo dnf copr enable -y $repo"
  fi
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
  
  local is_installed_cmd=false
  if [[ "$cmd" == *"|"* ]]; then
    local cmd1="${cmd%%|*}"
    local cmd2="${cmd##*|}"
    if command -v "$cmd1" &>/dev/null || command -v "$cmd2" &>/dev/null; then
      is_installed_cmd=true
    fi
  else
    if command -v "$cmd" &>/dev/null; then
      is_installed_cmd=true
    fi
  fi

  if $is_installed_cmd; then
    ok "${cmd//|//} already installed"
    return
  fi
  info "Installing ${cmd//|//} ..."
  
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

# ── Pre-flight Check ──────────────────────────────────────────────────────────
head "Pre-flight Check"

APPS=(
  "cc|gcc:Build Tools"
  "cargo:Rust Toolchain"
  "cargo-binstall:cargo-binstall"
  "zsh:zsh"
  "tmux:tmux"
  "git:git"
  "stow:stow"
  "starship:starship"
  "rg:ripgrep"
  "delta:git-delta"
  "dust:dust"
  "procs:procs"
  "bat|batcat:bat"
  "eza:eza"
  "fd|fdfind:fd-find"
  "zoxide:zoxide"
  "tldr:tealdeer"
  "fzf:fzf"
  "yazi:yazi"
  "lazygit:lazygit"
  "nvim:neovim"
  "atuin:atuin"
  "btop:btop"
  "mise:mise"
  "topgrade:topgrade"
)

installed_apps=()
missing_apps=()

for entry in "${APPS[@]}"; do
  cmd="${entry%%:*}"
  name="${entry##*:}"
  
  is_installed_cmd=false
  if [[ "$cmd" == *"|"* ]]; then
    cmd1="${cmd%%|*}"
    cmd2="${cmd##*|}"
    if command -v "$cmd1" &>/dev/null || command -v "$cmd2" &>/dev/null; then
      is_installed_cmd=true
    fi
  else
    if command -v "$cmd" &>/dev/null; then
      is_installed_cmd=true
    fi
  fi

  if $is_installed_cmd; then
    installed_apps+=("$name")
  else
    missing_apps+=("$name")
  fi
done

if [[ ${#installed_apps[@]} -gt 0 ]]; then
  echo -e "\n${BOLD}Installed:${RESET}"
  for name in "${installed_apps[@]}"; do echo -e "  ${GREEN}✔${RESET} $name"; done
fi

if [[ ${#missing_apps[@]} -gt 0 ]]; then
  echo -e "\n${BOLD}Missing (Will be installed):${RESET}"
  for name in "${missing_apps[@]}"; do echo -e "  ${YELLOW}✗${RESET} $name"; done
  
  echo ""
  if ! $DRY_RUN; then
    read -p "Proceed with installation? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${RED}Installation aborted by user.${RESET}"
      exit 0
    fi
  fi
else
  echo -e "\n${GREEN}All applications are already installed!${RESET}"
  
  echo ""
  if ! $DRY_RUN; then
    read -p "Do you want to restow your dotfiles? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${RED}Aborted by user.${RESET}"
      exit 0
    fi
  fi
fi

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
smart_install "bat|batcat" bat bat
smart_install eza eza eza
smart_install "fd|fdfind" fd-find fd-find
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

# Lazygit specialized install for Fedora
if ! command -v lazygit &>/dev/null; then
  if [[ "$PKG_FAMILY" == "fedora" ]]; then
    fedora_copr "atim/lazygit"
    pkg_install lazygit
  else
    smart_install lazygit lazygit lazygit
  fi
else
  ok "lazygit already installed"
fi
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


# ── GNU Stow & Deploy ─────────────────────────────────────────────────────────
head "GNU Stow — Deploy Configs"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
info "Stowing all packages from $DOTFILES_DIR ..."

for pkg in atuin bash btop fonts fzf git lazygit mise nvim procs ripgrep shells starship tealdeer tmux topgrade yazi zsh; do
  if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
    # Check for conflicts first using a dry run
    conflict_output=$(stow --dir="$DOTFILES_DIR" --target="$HOME" --no --restow "$pkg" 2>&1 || true)
    if echo "$conflict_output" | grep -q "would cause conflicts"; then
      echo "$conflict_output" | grep "existing target" | sed 's/.*existing target \([^ ]*\).*/\1/' | while read -r conflict_file; do
        target_file="$HOME/$conflict_file"
        if [[ -e "$target_file" && ! -L "$target_file" ]]; then
          warn "Backing up conflicting file: ~/$conflict_file -> ~/${conflict_file}.bak"
          mv "$target_file" "${target_file}.bak"
        fi
      done
    fi
    run "stow --dir=\"$DOTFILES_DIR\" --target=\"$HOME\" --restow \"$pkg\""
    ok "stowed: $pkg"
  fi
done

# ── Post-install ──────────────────────────────────────────────────────────────
head "Post-install"
if command -v tldr &>/dev/null; then run "tldr --update"; fi
if command -v yazi &>/dev/null && command -v ya &>/dev/null; then run "ya pack -i"; fi

# Zim Framework Sync
ZIM_FW="${ZDOTDIR:-$HOME}/.zim/zimfw.zsh"
if [[ -f "$ZIM_FW" ]]; then
  info "Syncing Zim framework..."
  # Try install/build. If it fails due to module issues, we suggest a reinstall
  if ! run "ZIM_HOME=\"\${ZDOTDIR:-\$HOME}/.zim\" zsh \"$ZIM_FW\" install"; then
    warn "Zim sync had issues. If you see 'Module was not installed using git', run: zsh \"$ZIM_FW\" reinstall"
  fi
elif [[ ! -d "${ZDOTDIR:-$HOME}/.zim" ]]; then
  info "Installing Zim framework..."
  run "mkdir -p \"\${ZDOTDIR:-\$HOME}/.zim\""
  run "curl -fsSL https://raw.githubusercontent.com/zimfw/zimfw/master/zimfw.zsh -o \"$ZIM_FW\""
  run "ZIM_HOME=\"\${ZDOTDIR:-\$HOME}/.zim\" zsh \"$ZIM_FW\" install"
fi

echo -e "\n${GREEN}${BOLD}✔ Barbarous CLI environment installed and configured.${RESET}"
echo -e "${YELLOW}${BOLD}⚠  Please log out and log back in (or restart your terminal) for all changes to take effect.${RESET}\n"
