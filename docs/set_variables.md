# Common Environmental Variables in Dotfiles

This document analyzes the environmental variables used in various curated dotfiles (located in `inbox/`) and explains the rationale behind them. Use this as a reference when configuring **Barbarous Core**.

## 1. Foundation Variables
These are essential for a functional and portable CLI.

| Variable | Typical Value | Why they set it |
| :--- | :--- | :--- |
| `PATH` | `$HOME/.local/bin`, `$HOME/.cargo/bin`, `$(brew --prefix)/bin` | **Essential.** Ensures custom scripts and language-specific binaries (Rust, Go, Node) are executable from any directory. |
| `EDITOR` | `nvim` or `vim` | Sets the global default editor for Git, Crontab, and other system tools. |
| `LANG` | `en_US.UTF-8` | Ensures consistent terminal encoding and correct rendering of NerdFonts/icons. |
| `XDG_CONFIG_HOME` | `$HOME/.config` | Follows the XDG specification to keep the home directory clean by storing configs in a central subfolder. |

## 2. Efficiency & Shell Behavior
Variables that optimize the interactive user experience.

| Variable | Typical Value | Why they set it |
| :--- | :--- | :--- |
| `KEYTIMEOUT` | `1` | Reduces the delay when switching modes in Zsh/Bash Vi-mode. |
| `FZF_DEFAULT_COMMAND` | `fd --type f --hidden` | Optimizes `fzf` by using faster search tools like `fd`. |
| `TERM` | `xterm-256color` | Ensures the terminal supports 256 colors for themes and syntax highlighting. |

## 3. Tool-Specific Integration
Tailored for specific development workflows.

| Variable | Typical Value | Why they set it |
| :--- | :--- | :--- |
| `STARSHIP_CONFIG` | `~/.config/starship.toml` | Custom path for the Starship prompt configuration. |
| `KUBECONFIG` | `~/.kube/config` | Manages credentials for Kubernetes clusters. |
| `GOPATH` / `NVM_DIR` | `$HOME/go` / `$HOME/.nvm` | Manages local package installations for Go and Node.js. |
| `WSL_INTEROP` | *Managed path* | Enables interoperability between Linux and Windows in WSL. |

---

## 🏔️ Barbarous Core Strategic Baseline

To ensure a unified and high-performance experience across the **Barbarous Core** ecosystem, these dotfiles should establish a robust configuration baseline. By centralizing essential environmental variables in dedicated files like `zsh/env.zsh` or `bash/env.sh`, we provide a predictable, efficient, and standardized terminal environment for every user of the live ISO.

---

## 🛠️ General Recommendations for Any Distro

Whether you are using **Barbarous**, Fedora, Debian, or Arch, follow these best practices for a clean and portable environment:

1. **Standardize XDG Paths**: Always set `export XDG_CONFIG_HOME="$HOME/.config"`. This ensures most modern apps store their settings in one place instead of cluttering your home root.
2. **Use the Right File**: 
   - Set variables in `.zshenv` (for Zsh) or `.profile` (for Bash/General) if you want them available to non-interactive scripts and GUI applications.
   - Use `.zshrc` or `.bashrc` only for interactive settings (like aliases).
3. **Smart PATH Appending**: Avoid duplicating paths by using a check before adding to `PATH`:
   ```bash
   [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
   ```
4. **Security First**: **NEVER** export API tokens or passwords directly in your public dotfiles. Create a `.env.local` file, add it to `.gitignore`, and source it in your main config:
   ```bash
   [ -f ~/.env.local ] && source ~/.env.local
   ```
5. **Portable Editor**: If you use a specialized editor like `nvim`, always provide a fallback:
   ```bash
   export EDITOR=$(command -v nvim || command -v vim || command -v vi)
   ```

*Last updated: 2026-04-11*
