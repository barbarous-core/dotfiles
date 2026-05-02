# Mise Configuration

This directory contains the global configuration for `mise` (formerly `rtx`), the polyglot tool manager.

## Main Configuration
- **Location**: `.config/mise/config.toml`
- **Key Features**:
  - **Cargo Optimization**: Automatically uses `cargo-binstall` for faster Rust tool installations.
  - **Tool Management**: Defines global tool versions if needed.

## Reference Comparisons
For a detailed comparison of this setup against external dotfiles (Aetf, omerxx, etc.), see:
- [mise_comparison.md](../docs/mise_comparison.md)

## Best Practices
- **Project Specific**: Use `.mise.toml` in project roots for project-specific tool versions.
- **Plugins**: Most plugins are compatible with `asdf`.
- **Activation**: Ensure `eval "$(mise activate zsh)"` is in your `.zshrc`.
