# Disk Usage Tool Comparison: `du` vs `dust`

This document compares disk usage analysis strategies across the curated dotfiles in your `inbox`.

## 🛠 Summary of Implementations

| Repository | Preferred Tool | Key Logic / Alias |
| :--- | :--- | :--- |
| **Christian Lempa** | `dust` | Installed as a core tool via Homebrew in `bootstrap`. |
| **g0t4** | `du -h` (legacy) | Transitioning away from `du -h | sort -hr`. |
| **CodeOpsHQ** | `colourify du` | Uses `grc` (generic colouriser) to make standard `du` more readable. |
| **Brodie Robertson** | `du -h` | Simple aliases for directory size. |

---

## 🔍 Deep Dive

### 1. Christian Lempa (The Modern Approach)
Christian Lempa treats `dust` as a mandatory part of his environment. In his `.config/yadm/bootstrap` file, he ensures it is installed immediately:
```bash
brew install dust
```
**Advantage**: Instant visual tree structure with percentages, making it much faster to find "disk hogs" in a TTY.

### 2. g0t4 (The "Expanding Alias" Approach)
Wes Higbee (`g0t4`) has a sophisticated alias expansion system. He previously used complex `du` pipes but noted they are often redundant now with modern tools.
- **Legacy Alias**: `alias du='du -h | sort -hr'`
- **Current Strategy**: Prefers using tools that handle sorting and formatting natively (like `dust`).

### 3. CodeOpsHQ (The "Classic" Polish)
If `dust` is not available, CodeOpsHQ uses `grc` to add high-contrast colors to the standard `du` command:
```bash
alias du='colourify du'
```
**Advantage**: Works on any system without needing Rust-based tools, but lacks the "tree" visualization of `dust`.

---

## 💡 Recommendation for Barbarous Core

Since you are in a **TTY (kmscon)** environment, `dust` is significantly superior to `du` because:
1. It uses a **vertical tree** which is easier to read on a console screen.
2. It provides **percentage bars** which give instant visual feedback.
3. It **automatically sorts** by size, saving you from typing `| sort -hr`.

### Recommended Alias:
I suggest adding this to your `aliases` to ensure `dust` is your go-to tool:
```bash
alias du='dust'
```
