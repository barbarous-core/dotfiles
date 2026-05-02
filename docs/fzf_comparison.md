# FZF Configuration Comparison

This document compares the `fzf` configurations found in the `@/home/mohamed/dotfiles/inbox` directory. The configurations range from simple aesthetic tweaks to complex workflow integrations.

## 1. Appearance & UI Styling

Several configurations focus on customizing the look of `fzf` to match specific color schemes (like Tokyo Night or Catppuccin).

| Repository | Key UI Features | Notable Flags |
| :--- | :--- | :--- |
| **CodeOpsHQ** | Rounded borders, Tokyo Night colors, inline-right info. | `--border=rounded`, `--info=inline-right`, `--layout=reverse` |
| **linkarzu** | Deeply themed colors synced with a central colorscheme file. | Custom `--color` tokens for every element (fg, bg, hl, info, etc.) |
| **elijahmanor** | Custom pointers and prompts for specific tools. | `--pointer=""`, `--prompt=" Neovim Config  "` |

### Example: CodeOpsHQ's Tokyo Night Style
```bash
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=rounded \
  --color=border:#27a1b9 \
  --color=fg:#c0caf5 \
  --color=gutter:#16161e \
  --color=header:#ff9e64 \
  --color=hl+:#2ac3de \
  --color=hl:#2ac3de \
  --color=info:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#ff007c \
  --color=prompt:#2ac3de \
  --color=query:#c0caf5:regular \
  --color=scrollbar:#27a1b9 \
  --color=separator:#ff9e64 \
  --color=spinner:#ff007c \
"
```

---

## 2. Core Behavior & Search Engines

The command used to feed data into `fzf` significantly impacts performance and what files are shown (e.g., hidden files, git-ignored files).

| Repository | Default Command | Logic / Tools |
| :--- | :--- | :--- |
| **omerxx** | `fd --type f --hidden --follow` | Uses `fd` (fast, respects `.gitignore`). |
| **CodeOpsHQ** | `fzf --preview 'bat ... {}'` | Aliases `fzf` itself to always include a `bat` preview. |
| **Standard** | `find . -type f` | Fallback when modern tools like `fd` aren't used. |

---

## 3. Shell Completion (Zsh)

Two main approaches to shell integration were observed:

- **fzf-tab**: Used by **CodeOpsHQ** and **dreamsofautonomy**. This replaces the standard Zsh completion menu with an `fzf` window.
  ```zsh
  zinit light Aloxaf/fzf-tab
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
  ```
- **Native Integration**: Newer `fzf` versions support a native Zsh script.
  ```zsh
  source <(fzf --zsh)
  ```

---

## 4. Advanced Workflow Aliases (The "Power User" Section)

**Elijah Manor**'s configuration stands out for using `fzf` as a UI layer for complex tasks.

### 🚀 Git & GitHub Workflows
- **`cb` (Branch Checkout)**: Lists branches with a `git diff` preview.
  ```bash
  alias cb='git branch --sort=-committerdate | fzf --header "Checkout Recent Branch" --preview "git diff {1} --color=always" --pointer="" | xargs git checkout'
  ```
- **`ghpr` (GitHub PRs)**: Select and checkout Pull Requests with a preview of the PR body.

### 📦 Development Utilities
- **`runr` (NPM Scripts)**: Parses `package.json` with `jq` and lets you select a script to run with a preview of the script's content.
- **`nvims` (Neovim Switcher)**: Quickly switch between different Neovim configurations (AstroNvim, LazyVim, NvChad) using `NVIM_APPNAME`.
- **`jqf` (Interactive JQ)**: An interactive playground for testing `jq` filters on a file.

### 📂 File Navigation (omerxx)
- **`fcd`**: Fuzzy `cd` into subdirectories.
- **`fv`**: Fuzzy find a file and open it in `nvim`.
  ```bash
  fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }
  ```

---

## Summary Recommendation

1. **For Aesthetics**: Adopt the **CodeOpsHQ** `FZF_DEFAULT_OPTS` but customize the colors to your liking.
2. **For Completion**: Use **`fzf-tab`** for a much better `cd` and command completion experience.
3. **For Productivity**: The **`cb`** (branch checkout) and **`nvims`** (config switcher) from **Elijah Manor** are highly recommended for any developer's toolkit.
