# 🏠 Dotfiles

> Centralized configuration ecosystem managed with [GNU Stow](https://www.gnu.org/software/stow/), powering the **Barbarous** distribution and any Linux workstation.

---

## 📖 Overview

This repository is the single source of truth for all personal system configurations, shell aliases, automation scripts, and console troubleshooting fixes. It is designed to be **portable**, **reproducible**, and **version-controlled** — deploy the same environment on any machine with a single command.

The dotfiles are structured as **Stow packages**: each top-level directory is a self-contained package that mirrors the target home directory tree. Stow creates symlinks from `~/` into this repo, keeping everything tracked in Git.

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
| — | *No packages yet — table will be updated as dotfiles are added.* | — |

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

| [fix_path.sh](scripts/fix_path.sh) | Fixes "command not found" by standardizing PATH in .bashrc |
| [setup_sudo.sh](scripts/setup_sudo.sh) | Automates sudo installation and user configuration |

<!-- UPDATE: Add a row each time a new script is created -->

---

## 📚 Documentation

Project documentation, roadmaps, and configuration checklists.

| File | Description |
|------|-------------|
| [shell_customization.md](docs/shell_customization.md) | A roadmap for shell optimization and Barbarous Core personalization |

<!-- UPDATE: Add a row each time a new doc file is created -->

---

## 🔧 Console Fixes

Documented solutions for recurring console and system issues — a personal troubleshooting knowledge base.

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
| 2026-04-10 | 🎉 Initial README created — repository bootstrapped |
| 2026-04-10 | 🛠️ Added PATH fix and Sudo setup scripts |
| 2026-04-11 | 📖 Added docs directory and shell customization roadmap |

<!-- UPDATE: Add a row for each significant change -->

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) — free to use, modify, and distribute.
