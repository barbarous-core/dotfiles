# Tealdeer / tldr — Inbox Configuration Audit

An audit of all 26 inbox repositories for `tldr` / `tealdeer` usage.
No repository ships a dedicated **tealdeer `config.toml`**, so this document
focuses on the patterns that were found and derives a recommended setup.

---

## Summary Table

| Repo | Pattern | File |
| :--- | :--- | :--- |
| **g0t4** | Full Zsh **completion plugin** for tldr-c-client | `zsh/universals/3-last/tldr.plugin.zsh` |
| **g0t4** | Installs `tldr` via **cloud-init** (WSL / Ubuntu) | `install/cloud-init/wsl-dotfiles.yaml` |
| **Aloxaf** | Short **alias** `h="tldr"` | `zsh/.config/zsh/snippets/alias.zsh` |
| **elijahmanor** | Lists `tldr` in a **fzf command-picker** array | `zsh/.zshrc` |
| **jpmcb** | Installs `tldr` via **apt** in a provisioning script | `vagrant-workstations/ubuntu/focal64/configs/system.sh` |
| **linkarzu** | Word `tldr` appears only in a Neovim spell dictionary | `neovim/neobean/spell/en.utf-8.add` _(not a config)_ |

---

## Pattern Details

### 1. g0t4 — Zsh Completion Plugin (`tldr.plugin.zsh`)

The richest tldr integration in the inbox. It adds **`compctl`-style tab-completion**
for the C implementation of tldr, sourcing page lists directly from the local cache.

```zsh
# ~/.tldrc/tldr/pages/{common,linux,osx,sunos}
_tldr_get_files() {
  local files="$(find $HOME/.tldrc/tldr/pages/$1 -name '*.md' -exec basename -s .md {} +)"
  IFS=$'\n\t'
  for f in $files; do echo $f; done
}

_tldr_complete() {
  local word="$1"
  local cmpl=""
  if   [ "$word" = "-"  ]; then cmpl=$(echo $'\n-v\n-h\n-u\n-c\n-p\n-r' | sort)
  elif [ "$word" = "--" ]; then cmpl=$(echo $'--version\n--help\n--update\n--clear-cache\n--platform\n--render' | sort)
  else
    if [ -d "$HOME/.tldrc/tldr/pages" ]; then
      cmpl="$(_tldr_get_files common | sort | uniq)"
      [ "$(uname)" = "Linux" ] && cmpl="${cmpl}$(_tldr_get_files linux | sort | uniq)"
    fi
  fi
  reply=( "${(ps:\n:)cmpl}" )
}

compctl -K _tldr_complete tldr
```

> **Note**: Uses the older `compctl` API (pre-zsh 3.1). The author notes that a
> `compdef`-style version exists in `tldr-node-client` but requires an unsupported flag.
> For modern Zsh with `compsys`, use the built-in completions shipped with **tealdeer**.

---

### 2. g0t4 — Cloud-Init Package Install

Installs the apt `tldr` package (the Python client) as part of an Ubuntu/WSL bootstrap:

```yaml
# install/cloud-init/wsl-dotfiles.yaml
packages:
  - tldr
```

> For Barbarous (Fedora/rpm), prefer `cargo install tealdeer` or
> `dnf install tealdeer` if available in the repos.

---

### 3. Aloxaf — Quick-Access Alias

Remaps `h` to `tldr` for one-keystroke help lookups:

```zsh
# alias.zsh
alias h="tldr"
```

Clean and ergonomic — pairs well with the pattern of `man` → `tldr` fallback.

---

### 4. elijahmanor — fzf Command Picker

Lists `tldr` alongside `lazygit`, `btop`, `navi`, etc. in an fzf-driven
interactive tool launcher:

```zsh
local dev_commands=(
  'tz' 'task' 'watson' 'archey' 'ncdu'
  'fkill' 'lazydocker' 'ntl' 'ranger'
  'speed-test' 'serve' 'vtop' 'htop' 'btop'
  'lazygit' 'gitui' 'tig' 'tldr'
  'calcurse' 'cmatrix' 'cowsay' 'exa' 'fd'
  'navi' 'neofetch' 'newsboat' 'nnn' 'tree'
  'vhs' 'vifm' 'zellij' 'tmux' 'zoxide'
)
alias dev='printf "%s\n" "${dev_commands[@]}" | fzf --height 20% --header Commands | bash'
```

> Useful as a **discovery tool** for available CLI programs.

---

### 5. jpmcb — apt Provisioning

Installs `tldr` as part of a Vagrant Ubuntu VM setup:

```bash
# configs/system.sh
apt install -y \
  tldr \
  vim
```

---

## Key Finding

**None of the 26 repos configure tealdeer itself** (no `~/.config/tealdeer/config.toml`).
This is likely because tealdeer works well out of the box and most users only
alias it or rely on its default output style.

---

## Recommended Barbarous Setup

Based on the patterns above, here is a minimal but effective tealdeer integration:

### Installation

```bash
# Fedora / Barbarous Core
cargo install tealdeer

# Or via dnf if packaged:
# dnf install tealdeer
```

### Shell Integration (Zsh)

```zsh
# ~/.config/zsh/aliases.zsh  (or your aliases module)

# Quick help — one keystroke (Aloxaf pattern)
alias h="tldr"

# Update the local cache on first run (tealdeer-specific)
# tldr --update
```

### Tealdeer Config (`~/.config/tealdeer/config.toml`)

Tealdeer supports a TOML config for styling and update intervals.
None found in the inbox — but the official defaults are sensible:

```toml
# ~/.config/tealdeer/config.toml

[display]
compact = false           # Show page description header
use_pager = false         # Set true to pipe through $PAGER

[updates]
auto_update = true        # Silently refresh cache after interval
auto_update_interval_hours = 720  # 30 days
```

### Zsh Completions (tealdeer ships its own)

```zsh
# In .zshrc — tealdeer provides a _tldr compdef function
# Just ensure the completion is generated and sourced:
tldr --print-completions zsh > "${ZDOTDIR:-$HOME}/.config/zsh/completions/_tldr"
fpath=("${ZDOTDIR:-$HOME}/.config/zsh/completions" $fpath)
```

> This supersedes the older `compctl` approach used by g0t4's plugin.

---

## Quick Reference: tldr vs tealdeer

| Feature | `tldr` (Python/Node client) | `tealdeer` (Rust client) |
| :--- | :---: | :---: |
| Speed | Slower | **Instant** |
| Offline cache | ✅ | ✅ |
| Auto-update | Manual | ✅ configurable |
| Config file | ❌ | ✅ TOML |
| Zsh completions | Via plugin | ✅ built-in |
| Fedora package | `tldr` (Python) | `tealdeer` (or cargo) |
| Alias | `tldr` | `tldr` (same binary name) |

> **Recommendation**: Use `tealdeer`. The binary is still invoked as `tldr`,
> so all inbox alias patterns (`alias h="tldr"`, etc.) apply without changes.
