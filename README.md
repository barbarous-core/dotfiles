# 🏠 Dotfiles

> Centralized configuration ecosystem managed with [GNU Stow](https://www.gnu.org/software/stow/), powering the **Barbarous** distribution and any Linux workstation.

---

## 📖 Overview

This repository is the single source of truth for all personal system configurations, shell aliases, automation scripts, and console troubleshooting fixes. It is designed to be **portable**, **reproducible**, and **version-controlled** — deploy the same environment on any machine with a single command.

The dotfiles are structured as **Stow packages**: each top-level directory is a self-contained package that mirrors the target home directory tree. Stow creates symlinks from `~/` into this repo, keeping everything tracked in Git.

---

## 🏗️ How This Repo Was Created

The architectural philosophy and content of this repository follow these strict principles:

- **CLI Only**: This repository is designed exclusively for command-line (CLI) and Terminal User Interface (TUI) applications. **No GUI applications** are configured or managed here, ensuring a pure, lightweight, and TTY-compatible environment.
- **Curated Foundations**: The configurations are heavily inspired by the [Omarchy](https://github.com/omarchy) dotfiles, and carefully audited repositories from famous developer YouTubers and power users. The full registry of tracked external repositories is available in the [inbox_repos.md](docs/inbox_repos.md) tracker.
- **Rigorous Auditing**: Rather than blindly copying configurations, each tool's setup was determined by cross-referencing and comparing the dotfiles of different creators to identify best practices. These decisions are explained in detail within the `docs/[APP]_comparison.md` files (for example, see [tmux_comparison.md](docs/tmux_comparison.md) or [fzf_comparison.md](docs/fzf_comparison.md)).

---

## 🚀 Quick Start

### Prerequisites

- [GNU Stow](https://www.gnu.org/software/stow/) — `sudo dnf install stow` (Fedora) / `sudo apt install stow` (Debian) / `sudo pacman -S stow` (Arch)
- [Git](https://git-scm.com/) — `sudo dnf install git` (Fedora) / `sudo apt install git` (Debian) / `sudo pacman -S git` (Arch)

### Installation

```bash
# Clone the repo into your home directory
git clone <repo-url> ~/dotfiles

# Enter the directory
cd ~/dotfiles

# Stow a specific package (e.g. bash)
stow bash

# Stow everything at once
stow */
```

### Uninstalling a Package

```bash
cd ~/dotfiles
stow -D <package-name>
```

---

## 🧰 Installed Applications

This environment automatically provisions a modern, high-performance CLI toolchain using the `install.sh` script:

### 🦀 Core Tools & Dependencies
- 🦀 **Rust Toolchain** (`rustup` / `cargo`)
- 🐚 **zsh** - Primary shell
-  پو **bash** - Fallback shell (installed by default on any distro)
- 🪟 **tmux** - Terminal multiplexer
- 🌿 **git** - Version control
- 📦 **GNU Stow** - Dotfile symlink manager
- 🚀 **Starship** - Cross-shell prompt

### ⚡ Modern CLI Replacements
- 🔍 **ripgrep** (`rg`) - `grep` replacement
- 🎨 **delta** - `diff` replacement with syntax highlighting
- 📊 **dust** - `du` replacement
- ⚙️ **procs** - `ps` replacement
- 🦇 **bat** - `cat` replacement
- 📁 **eza** - `ls` replacement
- 🔎 **fd** - `find` replacement
- 🗺️ **zoxide** - Smarter `cd`
- 📚 **tealdeer** (`tldr`) - Offline `man` pages

### 🛠️ Fuzzy Finding & Workflows
- 🪄 **fzf** - Command-line fuzzy finder
- 🗄️ **yazi** - Blazing fast terminal file manager
- 📦 **lazygit** - Terminal UI for git
- 📝 **nvim** - Neovim text editor
- 🐢 **atuin** - Magical shell history synchronization
- 📈 **btop** - Modern system resource monitor

### 📦 Package & Environment Management
- 🛠️ **mise** - Polyglot tool version manager
- ⬆️ **topgrade** - Master system update utility
- 📦 **cargo-binstall** - Fast pre-compiled Rust binary installer

### 🔌 Frameworks & Plugins
- ⚡ **Zim Framework** - High-performance Zsh plugin manager
- 🔌 **tpm** - Tmux Plugin Manager

---

## 📂 Repository Structure

```
dotfiles/
├── README.md              # ← You are here
├── docs/                  # Project documentation & roadmaps
├── <package>/             # Each directory is a Stow package
│   └── .config/           # Mirrors ~/.<config> structure
│       └── <app>/
│           └── config
├── scripts/               # Custom automation & utility scripts
├── aliases/               # Shell alias definitions
└── fixes/                 # Documented console problem fixes
```

> **Convention:** Each Stow package directory mirrors the home directory tree.  
> For example, `bash/.bashrc` gets symlinked to `~/.bashrc`.

---

## 🔗 Stow Packages

| Package | Description | Target |
|---------|-------------|--------|
| `bash` | Core bash configuration, prompt settings, and env variables | `~/.bashrc` |

<!-- UPDATE: Add a row each time a new stow package is created -->

---

## ⌨️ Aliases

Centralized shell aliases for everyday productivity.

| Alias | Command | Description |
|-------|---------|-------------|
| — | — | *No aliases yet — table will be updated as aliases are added.* |

<!-- UPDATE: Add a row each time a new alias is created -->

---

## 📜 Scripts

Custom scripts for automation, maintenance, and workflow optimization.

| Script | Description |
|--------|-------------|
| [install.sh](scripts/install.sh) | Automatically detects distro, installs all modern CLI tools, and stows dotfiles |
| [fix_path.sh](scripts/fix_path.sh) | Fixes "command not found" by standardizing PATH in .bashrc |
| [setup_sudo.sh](scripts/setup_sudo.sh) | Automates sudo installation and user configuration |

<!-- UPDATE: Add a row each time a new script is created -->

---

## 📚 Documentation

Project documentation, roadmaps, and configuration checklists.

| File | Description |
|------|-------------|
| [cli_productivity_audit.md](docs/cli_productivity_audit.md) | The master roadmap tracking the completion of the 100% optimized CLI environment |
| [inbox_repos.md](docs/inbox_repos.md) | Registry of external dotfile repositories curated for configuration research |
| [shell_customization.md](docs/shell_customization.md) | A roadmap for shell optimization and Barbarous Core personalization |
| [set_variables.md](docs/set_variables.md) | Documentation of common environmental variables and their rationale |
| [bash_config_comparison.md](docs/bash_config_comparison.md) | Research and comparison of external Bash configurations |
| [zsh_config_comparison.md](docs/zsh_config_comparison.md) | Research and comparison of external Zsh configurations |
| [starship_comparison.md](docs/starship_comparison.md) | Research and comparison of external Starship prompt configurations |
| [tmux_comparison.md](docs/tmux_comparison.md) | Research and comparison of external Tmux configurations |
| [fzf_comparison.md](docs/fzf_comparison.md) | Research and comparison of external Fzf configurations |
| [yazi_comparison.md](docs/yazi_comparison.md) | Research and comparison of Yazi file manager configurations |
| [mise_comparison.md](docs/mise_comparison.md) | Research and comparison of Mise tool manager configurations |
| [tealdeer_comparison.md](docs/tealdeer_comparison.md) | Research and comparison of Tealdeer/tldr configurations |
| [dust_comparison.md](docs/dust_comparison.md) | Research and comparison of Dust (du alternative) configurations |
| [tty_productivity_audit.md](docs/tty_productivity_audit.md) | Assessment of TTY-specific workflows and console constraints |

<!-- UPDATE: Add a row each time a new doc file is created -->

---

## 🔧 Console Fixes

Documented solutions for recurring console and system issues — a personal troubleshooting knowledge base.

| # | Issue | Solution | Date |
|---|---|---|---|
| 1 | command not found | Standardized PATH export in .bashrc | 2026-04-10 |
| 2 | sudo installation | Scripted sudo install and sudoers config | 2026-04-10 |

<!-- UPDATE: Add a row each time a new console fix is documented -->

---

## 🐃 Barbarous Distribution

These dotfiles are a core component of **Barbarous** — a custom immutable Linux distribution built on **Fedora CoreOS**. During the Barbarous ISO build and first-boot process, this repository is cloned and stowed automatically to deliver a fully branded, pre-configured environment out of the box.

Key integration points:

- **Live ISO injection** — dotfiles are embedded into the ISO and applied during first boot via Ignition.
- **Immutable-friendly** — configurations live in `~/.config/` and respect the read-only root filesystem.
- **Reproducible** — the same dotfiles deploy identically on bare metal, VMs, and containers.

---

## 📝 Maintenance Rules

> **This README must be kept up to date.** On every change, update the relevant section:

| Action | Section to Update |
|--------|-------------------|
| New Stow package created | [Stow Packages](#-stow-packages) |
| New alias added | [Aliases](#️-aliases) |
| New script added | [Scripts](#-scripts) |
| Console problem fixed | [Console Fixes](#-console-fixes) |
| Change in `docs/` | [Documentation](#-documentation) |

---

## 📋 Changelog

| Date | Change |
|------|--------|
| 2026-05-02 | 🛠️ Created `install.sh` for automated, distro-agnostic toolchain provisioning |
| 2026-05-02 | 🚀 Achieved 100% completion of the Barbarous CLI Productivity Audit |
| 2026-05-02 | 📖 Generated extensive configuration comparison documentation for all modern CLI tools |
| 2026-05-02 | 🧰 Added complete list of managed installed applications to README |
| 2026-04-11 | 📖 Added docs directory and shell customization roadmap |
| 2026-04-10 | 🛠️ Added PATH fix and Sudo setup scripts |
| 2026-04-10 | 🎉 Initial README created — repository bootstrapped |

<!-- UPDATE: Add a row for each significant change -->

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) — free to use, modify, and distribute.
