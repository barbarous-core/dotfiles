# TTY-Optimized Productivity Audit (Barbarous Console)

Since you are targeting a **TTY environment** (with `kmscon`), your setup needs to be robust, high-contrast, and keyboard-driven without relying on GPU features like image previews.

## 1. The TTY Core: `tmux` is King
In a TTY, you don't have terminal tabs. **`tmux`** is your window manager.
- **`tmux-sessionizer`**: This is even more critical in TTY. It lets you fuzzy-jump between projects into separate tmux sessions.
- **Status Bar**: Keep it simple. Avoid heavy glyphs if the TTY font doesn't support them perfectly.

## 2. TTY-Friendly Tooling

| Tool | Status | TTY Compatibility |
| :--- | :--- | :--- |
| **`lazygit`** | Recommended | Works perfectly in 16-color/256-color TTYs. |
| **`fzf`** | ✅ Already Used | Switch to `--border=horizontal` or `none` if rounded borders look weird in your TTY font. |
| **`eza`** | ✅ Already Used | Use `--icons=always` only if you have a PSF/Console font with symbols. Otherwise, use `--icons=auto`. |
| **`yazi`** | Optional | Great, but disable image previews for TTY. |
| **`topgrade`** | **Essential** | The best way to keep a TTY-only system updated without manual typing. |

---

## 3. Configuration Tweaks for TTY

### 🎨 FZF Colors (High Contrast)
Standard TTYs often struggle with the subtle "Tokyo Night" colors. I recommend a "16-color" safe fallback for `FZF_DEFAULT_OPTS` if `TERM=linux`.

### 🔤 Font & Icons
- Ensure your `kmscon` is using a font like **Terminus** or a **Nerd Font** patched console font.
- If icons look like boxes in the TTY, we should add a check to disable them when `TERM=linux`.

### 🇸🇦 Arabic (Bicon)
You already have `bicon` in your `.zshrc`. This is the best practice for Arabic in TTY.

---

## 4. Proposed "TTY-First" Additions

### `topgrade` Configuration
Since you asked about it, here is a minimal `topgrade.toml` for a TTY workstation:
```toml
[misc]
assume_yes = true
no_retry = true

[git]
repos = ["~/dotfiles"]

[commands]
"Clean Cache" = "sudo dnf clean all"
```

### `cb` (Git Branch) for TTY
The diff preview works great in TTY because it's all text. You might want to use `git diff --color=always --stat` for a more compact view on smaller TTY screens.
