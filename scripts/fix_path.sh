#!/bin/bash
# Fixes "command not found" issues by ensuring standard paths are in the environment.
# Adds common system binary paths to ~/.bashrc

echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"' >> ~/.bashrc
echo "Standard PATH exported to ~/.bashrc"
echo "To apply changes, run: source ~/.bashrc"
