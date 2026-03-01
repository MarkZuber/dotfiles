#!/bin/bash

# Bazzite/Immutable Fedora Setup Script
# ======================================
# This script is optimized for immutable systems like Bazzite.
# Installation priority:
#   1. Flatpak (for GUI apps - sandboxed, no reboot needed)
#   2. Homebrew (for CLI tools - userspace, no reboot needed)
#   3. Userspace installs (nvm, rustup, oh-my-zsh, fonts)
#   4. rpm-ostree (last resort - requires reboot, can conflict with updates)
#
# First thing to do is:
# mkdir -p ~/repos
# cd ~/repos
# git clone https://github.com/markzuber/dotfiles
# then run ~/repos/dotfiles/bazzite_config_immutable.sh

set -e

echo "=== Bazzite Immutable System Setup ==="
echo ""

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

command_exists() {
    command -v "$1" &> /dev/null
}

# Create symlink, removing existing file/dir if it's not already a link
make_link() {
    local target="$1"
    local link_name="$2"

    if [ -L "$link_name" ]; then
        # Already a symlink, update it
        ln -sf "$target" "$link_name"
    elif [ -e "$link_name" ]; then
        # Exists but not a symlink, remove and link
        rm -rf "$link_name"
        ln -s "$target" "$link_name"
    else
        # Doesn't exist, just create the link
        ln -s "$target" "$link_name"
    fi
}

install_homebrew_if_needed() {
    if ! command_exists brew; then
        echo ">>> Installing Homebrew (Linuxbrew)..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for this session
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

        echo ">>> Homebrew installed. Adding to shell profiles..."
        # This will be sourced by .zshrc later, but add to .bashrc for now
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    else
        echo ">>> Homebrew already installed"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
}

# -----------------------------------------------------------------------------
# System update (rpm-ostree style)
# -----------------------------------------------------------------------------

echo ">>> Checking for system updates..."
rpm-ostree upgrade --check || true
echo "Note: Run 'rpm-ostree upgrade' and reboot if updates are available"
echo ""

# -----------------------------------------------------------------------------
# Install Homebrew and CLI tools
# -----------------------------------------------------------------------------

echo ">>> Setting up Homebrew for CLI tools..."
install_homebrew_if_needed

echo ">>> Installing CLI tools via Homebrew..."
# These tools work great from Homebrew and don't need system integration
brew install lsd fzf ripgrep neovim bat tmux neofetch git

# -----------------------------------------------------------------------------
# Git Credential Manager via Homebrew
# -----------------------------------------------------------------------------

echo ">>> Installing Git Credential Manager..."
brew install --cask git-credential-manager
git-credential-manager configure

# -----------------------------------------------------------------------------
# Flatpak apps (GUI applications)
# -----------------------------------------------------------------------------

echo ">>> Installing GUI applications via Flatpak..."

# Ensure Flathub is added (Bazzite should have this by default)
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# VS Code
echo ">>> Installing Visual Studio Code..."
flatpak install -y flathub com.visualstudio.code

# Ghostty - Check if available on Flathub, otherwise use alternative method
echo ">>> Installing Ghostty..."
if flatpak search com.mitchellh.ghostty 2>/dev/null | grep -q ghostty; then
    flatpak install -y flathub com.mitchellh.ghostty
else
    echo ">>> Ghostty not on Flathub, installing via Homebrew..."
    brew install --cask ghostty || brew install ghostty || {
        echo ">>> Ghostty: Consider using ujust to install from Bazzite's repos"
        echo ">>> Run: ujust install-ghostty (if available)"
    }
fi

# -----------------------------------------------------------------------------
# Wallpaper and Ghostty shaders (userspace)
# -----------------------------------------------------------------------------

echo ">>> Setting up repos directory..."
mkdir -p ~/repos
cd ~/repos

if [ ! -d ~/repos/wallpaper ]; then
    git clone https://github.com/markzuber/wallpaper
fi

if [ ! -d ~/repos/ghostty-shaders ]; then
    git clone --depth 1 https://github.com/hackr-sh/ghostty-shaders
fi

mkdir -p ~/.config/ghostty/ghostty-shaders
cp ~/repos/ghostty-shaders/*.glsl ~/.config/ghostty/ghostty-shaders/

cd ~

# -----------------------------------------------------------------------------
# Node.js via nvm (userspace - works perfectly on immutable systems)
# -----------------------------------------------------------------------------

echo ">>> Installing nvm..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
    echo ">>> nvm already installed"
fi

# -----------------------------------------------------------------------------
# Fonts (userspace - no system integration needed)
# -----------------------------------------------------------------------------

echo ">>> Installing fonts..."
mkdir -p ~/.local/share/fonts

if [ -f ~/repos/dotfiles/fonts/FiraCode.zip ]; then
    unzip -o ~/repos/dotfiles/fonts/FiraCode.zip -d ~/.local/share/fonts/
fi
if [ -f ~/repos/dotfiles/fonts/CascadiaCode.zip ]; then
    unzip -o ~/repos/dotfiles/fonts/CascadiaCode.zip -d ~/.local/share/fonts/
fi
if [ -f ~/repos/dotfiles/fonts/comic-shanns-mono-v1.3.0.zip ]; then
    unzip -o ~/repos/dotfiles/fonts/comic-shanns-mono-v1.3.0.zip -d ~/.local/share/fonts/
fi

fc-cache -fv

# -----------------------------------------------------------------------------
# Rust via rustup (userspace - works perfectly on immutable systems)
# -----------------------------------------------------------------------------

echo ">>> Installing Rust..."
if ! command_exists rustc; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo ">>> Rust already installed"
fi

# -----------------------------------------------------------------------------
# Zsh (rpm-ostree - needs system integration for login shell)
# -----------------------------------------------------------------------------

echo ">>> Installing zsh via rpm-ostree..."
if ! command_exists zsh; then
    echo ">>> Layering zsh package (will require reboot to take effect)..."
    rpm-ostree install --idempotent zsh
    NEEDS_REBOOT=true
else
    echo ">>> zsh already available"
fi

# -----------------------------------------------------------------------------
# Oh-My-Zsh and plugins (userspace)
# -----------------------------------------------------------------------------

echo ">>> Installing Oh-My-Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # Use RUNZSH=no to prevent it from starting zsh immediately
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo ">>> Oh-My-Zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo ">>> Installing zsh plugins..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
    git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
fi

# Powerlevel10k theme
echo ">>> Installing Powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# -----------------------------------------------------------------------------
# Symlink dotfiles
# -----------------------------------------------------------------------------

echo ">>> Linking dotfiles..."

# zshrc
make_link ~/repos/dotfiles/zsh/.zshrc ~/.zshrc

# ghostty config
mkdir -p ~/.config/ghostty
make_link ~/repos/dotfiles/ghostty/.config/ghostty/config ~/.config/ghostty/config

# For Flatpak Ghostty, also link to the Flatpak config location
mkdir -p ~/.var/app/com.mitchellh.ghostty/config/ghostty
make_link ~/repos/dotfiles/ghostty/.config/ghostty/config ~/.var/app/com.mitchellh.ghostty/config/ghostty/config

# p10k
make_link ~/repos/dotfiles/p10k/.p10k.zsh ~/.p10k.zsh

# nvim
make_link ~/repos/dotfiles/nvim/.config/nvim ~/.config/nvim

# tmux
make_link ~/repos/dotfiles/tmux/.tmux.conf ~/.tmux.conf

# editorconfig
make_link ~/repos/dotfiles/editorconfig/.editorconfig ~/.editorconfig

# gitconfig
make_link ~/repos/dotfiles/git/.gitconfig ~/.gitconfig

# -----------------------------------------------------------------------------
# Xbox controller (xone) - This is tricky on immutable systems
# -----------------------------------------------------------------------------

echo ">>> Xbox controller (xone) setup..."
echo "Note: xone requires kernel modules which is complex on immutable systems."
echo "Options:"
echo "  1. Check if Bazzite has built-in Xbox controller support (likely!)"
echo "  2. Use ujust if Bazzite provides an xone installer: ujust install-xone"
echo "  3. For advanced users: use rpm-ostree to layer akmod-xone if available"
echo ""
echo "Testing current Xbox controller support..."
if ls /dev/input/js* 2>/dev/null; then
    echo ">>> Game controllers detected. Xbox support may already work!"
else
    echo ">>> No controllers detected. Connect your controller and check Bazzite docs."
fi

# -----------------------------------------------------------------------------
# Add Homebrew to zshrc if not already there
# -----------------------------------------------------------------------------

if ! grep -q "linuxbrew" ~/.zshrc 2>/dev/null; then
    echo "" >> ~/.zshrc
    echo "# Homebrew" >> ~/.zshrc
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
fi

# -----------------------------------------------------------------------------
# Final notes
# -----------------------------------------------------------------------------

echo ""
echo "=== Setup Complete ==="
echo ""

if [ "$NEEDS_REBOOT" = true ]; then
    echo "IMPORTANT: A reboot is required for rpm-ostree changes (zsh)."
    echo "Run: systemctl reboot"
    echo ""
fi

echo "Post-setup tasks:"
echo "  1. Reboot if prompted above"
echo "  2. Change default shell to zsh: chsh -s \$(which zsh)"
echo "  3. Remap Caps Lock: System Settings > Keyboard > Advanced"
echo "  4. Configure VS Code fonts (run 'flatpak run com.visualstudio.code'):"
echo '     "editor.fontFamily": "Comic Shanns Mono"'
echo '     "terminal.integrated.fontFamily": "CaskaydiaCove Nerd Font Mono"'
echo "  5. Install Chrome if needed (flatpak install flathub com.google.Chrome)"
echo ""

# Show off
if command_exists neofetch; then
    neofetch
fi
