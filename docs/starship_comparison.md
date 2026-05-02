# Starship Configuration Comparison

This report compares your current Starship configuration with several community configurations located in your `inbox` directory.

## Configuration Profiles Overview

| Profile | Focus | Key Features |
| :--- | :--- | :--- |
| **Your Config** | Minimal & Consistent | Single-line, cyan-heavy theme, compact git status. |
| **Linkarzu** | DevOps & Visibility | Multi-line, includes Kubernetes, Time, Username, and Hostname. |
| **Omerxx** | Aesthetic & Functional | Catppuccin palette, split left/right prompt, Vi-mode support. |
| **Christian Lempa** | Descriptive | OS icons, verbose git status labels (e.g., "ahead=1"), multi-line. |
| **Brodie Robertson** | Extreme Minimalism | Disables almost all language modules for maximum performance. |

---

## Detailed Comparison

### 1. Layout & Format
*   **Your Config**: Simple single-line: `directory` -> `git` -> `character`.
*   **Linkarzu**: Multi-line layout. Shows `$all` modules followed by Kubernetes on a new line, then the character.
*   **Omerxx**: Uses `right_format` to push most information to the right side of the terminal, keeping the left prompt extremely clean (`directory` + `character`).
*   **Christian Lempa**: Multi-line with a custom prompt character (``) on the second line.

### 2. Color Schemes
*   **Your Config**: Heavily utilizes `bold cyan` for directory, branch, and status symbols.
*   **Linkarzu**: Uses hex codes (e.g., `#a6aaf1`, `#00a5ff`) for more precise color control.
*   **Omerxx**: Implements a full **Catppuccin Mocha** palette using a `[palettes]` block, providing a cohesive pastel aesthetic.

### 3. Git Status Representation
*   **Your Config**: Uses clean Nerd Font icons (``, ``, ``) with minimal noise.
*   **Christian Lempa**: Very verbose. Instead of just icons, it includes text like `[󰛿 modified=${count}]`.
*   **Omerxx**: Standard but clean, integrated into the right-hand prompt.

### 4. Advanced Modules
| Feature | Your Config | Linkarzu | Omerxx | Lempa |
| :--- | :--- | :--- | :--- | :--- |
| **Kubernetes** | ❌ | ✅ (Custom formatting) | ✅ (Conditional) | ✅ (Purple style) |
| **AWS** | ❌ | ❌ | ✅ (Profile/Region) | ❌ |
| **OS Symbols** | ❌ | ❌ | ❌ | ✅ (Arch/Ubuntu/Win) |
| **Time** | ❌ | ✅ (y/m/d H:M:S) | ❌ | ❌ |
| **Vi-Mode** | ❌ | ❌ | ✅ (Shows `[N]` for Normal) | ❌ |

---

## Recommendation & Inspiration

*   **For a cleaner look**: Consider **Omerxx's** `right_format` strategy. It keeps your typing area uncluttered while still showing git and language info.
*   **For better context**: **Christian Lempa's** OS symbols and **Linkarzu's** Kubernetes/Time modules are great if you work across different environments or clusters.
*   **For aesthetics**: You might want to adopt a palette like **Catppuccin** (from Omerxx) to move away from the standard ANSI cyan.

### Quick Snippet: Omerxx's Right Prompt
If you want to try the split prompt:
```toml
# In your starship.toml
format = """$directory$character"""
right_format = """$all"""
```
