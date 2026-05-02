# Yazi Configuration Comparison

I have analyzed the Yazi configurations found in your `inbox` directory. Currently, only two repositories provide Yazi setups: **CodeOpsHQ** and **linkarzu**.

## Summary Table

| Feature | CodeOpsHQ | linkarzu |
| :--- | :--- | :--- |
| **Philosophy** | Minimalist with specific plugins | Reference-heavy with minimal overrides |
| **Key Bindings** | Custom (Mount `M`, File Size `'s`) | Essential overrides (`Esc` to quit, `dd` to trash, `yy` to yank) |
| **Plugins** | Git integration, Full Border, Extra Metadata | Uses default plugin stack |
| **Structure** | Standard `.config/yazi` layout | Flatted `yazi` folder with reference defaults |
| **Unique Additions** | `spotter` and `prepend_fetchers` for Git | `show_hidden = true` by default |

---

## Detailed Analysis

### 1. CodeOpsHQ
Located at: `inbox/CodeOpsHQ/.config/yazi/`

This configuration is focused on extending Yazi's functionality via plugins:
- **Git Integration**: Uses `prepend_fetchers` to show git status for files and directories.
- **Visuals**: Includes `full-border` plugin in `init.lua` for a cleaner UI.
- **Spotter**: Implements `file-extra-metadata` as a spotter, likely for enhanced file previews.
- **Keymaps**:
    - `M`: Mount (requires a mount plugin).
    - `'s`: Show file size (using `what-size` plugin).

### 2. linkarzu
Located at: `inbox/linkarzu/yazi/`

Linkarzu's approach is more about having a solid baseline:
- **Reference Files**: Includes `yazi-default.toml` and `keymap-default.toml` which contain the full standard Yazi settings for easy reference.
- **Overrides**:
    - Sets `show_hidden = true`.
    - Keymaps focus on making Yazi feel more like a standard CLI tool:
        - `Esc`: Quit.
        - `o`: Create file/dir.
        - `dd`: Trash.
        - `yy`: Yank/Copy.
- **Aesthetics**: Includes a large `theme-dark.toml` with detailed color schemes (likely Catppuccin or similar).

## Recommendation

- If you want a **feature-rich** setup with Git indicators and better borders, look into **CodeOpsHQ**.
- If you want a **Vim-like** experience with clean keybindings and a comprehensive theme, **linkarzu** is a better starting point.
