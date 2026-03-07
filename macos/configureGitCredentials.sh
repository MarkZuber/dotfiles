#!/bin/bash

# Write macOS-specific git credential settings to ~/.gitconfig-local
# ~/.gitconfig includes this file, keeping OS-specific settings out of the committed config
git config --file ~/.gitconfig-local credential.helper osxkeychain

echo "Git credential helper set to osxkeychain in ~/.gitconfig-local."
