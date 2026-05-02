# Comparison of Bash Configurations in Dotfiles Inbox

This document provides a detailed comparison of Bash configurations identified within the `~/dotfiles/inbox` directory.

## 1. Prompt & Aesthetics

| User | Prompt Engine | Style/Features |
| :--- | :--- | :--- |
| **Brodie Robertson** | `starship` | Minimalist, fast, and modern. |
| **Linkarzu** | `starship` | Uses a custom `starship.toml` located in a specific dotfiles path. |
| **Ryanoasis** | `powerline-shell` | Uses a Python-based powerline script with a custom `_update_ps1` function. |
| **JD Pedersen** | Custom Bash Function | Features a multi-line prompt with git branch and status indicators (`parse_git_branch`, `parse_git_dirty`). |

## 2. Productivity Tools & Aliases

### File Listing & Navigation
*   **Linkarzu**: Replaces `ls` with `eza` (modern exa replacement) and `cd` with `zoxide`.
*   **JD Pedersen**: Uses `lsd` for listing and `zoxide` for navigation. Includes a unique `lsp` alias that uses `fzfimg.sh` for image previews.
*   **Ryanoasis**: Relies on standard `ls --color` but includes custom logic for screenfetch.

### Git Integration
*   **Ryanoasis**: The most advanced Git utility user. Includes `stashgrep` for searching through stashes and `gfp` for automated fetch/checkout/pull.
*   **JD Pedersen**: Standardizes Git commands with simple aliases like `commit`, `add`, `pull`, `npush`.
*   **Linkarzu**: Includes Kubernetes (`kubectl`) and Golang specific aliases alongside standard Git flow.

### File Inspection
*   **Linkarzu**: Aliases `cat` to `bat` for syntax-highlighted viewing.
*   **JD Pedersen**: Also uses `bat` but with specific theme overrides (`--theme ansi`).

## 3. History Management

*   **Ryanoasis**: Implements "Eternal Bash History" by setting `HISTSIZE` and `HISTFILESIZE` to empty (unlimited) and using a custom `~/.bash_eternal_history` file to prevent truncation.
*   **Linkarzu & JD Pedersen**: Both standardize on a `10,000` entry history limit, ensuring a balance between performance and searchability.

## 4. Technical Differences

### Shell Options (`shopt`)
*   **JD Pedersen**: Uses `shopt -s autocd` (allows typing a directory name to enter it) and `set -o vi` (vi-mode keybindings).
*   **Brodie Robertson**: Also enables vi-mode keybindings.

### OS Portability
*   **Linkarzu**: Features a robust `case "$(uname -s)"` block to handle environment variables and paths differently between macOS and Linux.
*   **i-tu**: Primarily focuses on macOS with specific NVM paths in the home directory.

### Archive Handling
*   **JD Pedersen**: Includes a comprehensive `ex()` function for extracting almost any archive type (`.tar.gz`, `.zip`, `.7z`, `.rar`, etc.) with a single command.

## 5. Summary Table

| Feature | Brodie Robertson | Linkarzu | Ryanoasis | JD Pedersen |
| :--- | :--- | :--- | :--- | :--- |
| **Complexity** | Low | High | Medium-High | High |
| **Modern Tools** | Starship | Eza, Bat, Zoxide, Fzf | Powerline | Lsd, Zoxide, Bat |
| **Git Awareness** | Low | Medium | High | High |
| **History Logic** | Default | Standard (10k) | Unlimited | Standard (10k) |
| **Vi Mode** | Yes | No | No | Yes |

