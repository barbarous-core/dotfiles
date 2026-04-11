#!/bin/bash
# Installs sudo and adds a specific user to the sudoers list.
# Usage: ./setup_sudo.sh <username> [--no-password]

IF_NOPASSWD=$2
TARGET_USER=$1

if [ -z "$TARGET_USER" ]; then
    echo "Error: Please specify a username."
    echo "Usage: ./setup_sudo.sh <username> [--no-password]"
    exit 1
fi

# Check if user already has sudo privileges
if command -v sudo >/dev/null 2>&1; then
    if groups "$TARGET_USER" 2>/dev/null | grep -E "\b(sudo|wheel)\b" >/dev/null || [ -f "/etc/sudoers.d/$TARGET_USER" ]; then
        echo "User $TARGET_USER is already in sudoer."
        exit 0
    fi
fi

echo "Switching to root to perform installation (password required)..."

su -c "
  # Detect package manager and install sudo
  if command -v apt-get &>/dev/null; then
    apt-get update && apt-get install -y sudo
  elif command -v dnf &>/dev/null; then
    dnf install -y sudo
  fi

  # Configure sudoers
  if [ \"$IF_NOPASSWD\" == \"--no-password\" ]; then
    echo \"$TARGET_USER ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/$TARGET_USER
    echo \"User $TARGET_USER added to sudoers with NOPASSWD.\"
  else
    echo \"$TARGET_USER ALL=(ALL) ALL\" > /etc/sudoers.d/$TARGET_USER
    echo \"User $TARGET_USER added to sudoers.\"
  fi
  
  chmod 0440 /etc/sudoers.d/$TARGET_USER
"
