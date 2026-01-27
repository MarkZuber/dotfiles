#!/bin/bash

# Bazzite Distrobox Dev Setup Script
# ===================================
# This script uses distrobox to install development tools in a Fedora container.
# - VSCode is already installed in the main Bazzite image
# - All package installations happen inside the distrobox
# - Ghostty is exported from the box to the host system
#
# First thing to do is:
# mkdir -p ~/repos
# cd ~/repos
# git clone https://github.com/markzuber/dotfiles
# then run ~/repos/dotfiles/bazzite_distrobox_devmate.sh

set -e

DISTROBOX_NAME="devmate"
DISTROBOX_IMAGE="registry.fedoraproject.org/fedora:latest"

echo "=== Bazzite Distrobox Dev Setup ==="
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
        ln -sf "$target" "$link_name"
    elif [ -e "$link_name" ]; then
        rm -rf "$link_name"
        ln -s "$target" "$link_name"
    else
        ln -s "$target" "$link_name"
    fi
}

# Run a command inside the distrobox
distrobox_run() {
    distrobox enter "$DISTROBOX_NAME" -- "$@"
}

# -----------------------------------------------------------------------------
# Create the Distrobox
# -----------------------------------------------------------------------------

echo ">>> Creating distrobox '$DISTROBOX_NAME' with Fedora..."
if ! distrobox list | grep -q "$DISTROBOX_NAME"; then
    distrobox create --name "$DISTROBOX_NAME" --image "$DISTROBOX_IMAGE" --yes
    echo ">>> Distrobox '$DISTROBOX_NAME' created"
else
    echo ">>> Distrobox '$DISTROBOX_NAME' already exists"
fi

# -----------------------------------------------------------------------------
# Install packages inside the distrobox
# -----------------------------------------------------------------------------

echo ">>> Installing development packages inside distrobox..."

# Update and install CLI tools via dnf inside the box
distrobox_run sudo dnf update -y
distrobox_run sudo dnf install -y \
    git \
    zsh \
    neovim \
    tmux \
    fzf \
    ripgrep \
    bat \
    neofetch \
    unzip \
    curl \
    wget \
    gcc \
    gcc-c++ \
    make \
    cmake \
    openssl-devel \
    fontconfig-devel \
    freetype-devel \
    libxcb-devel \
    libxkbcommon-devel \
    pkg-config

# lsd is not in Fedora repos, install via cargo later or use alternative
echo ">>> Note: lsd will be installed via cargo after Rust setup"

# -----------------------------------------------------------------------------
# Install Ghostty inside the distrobox and export it
# -----------------------------------------------------------------------------

echo ">>> Installing Ghostty inside distrobox..."

# Check if ghostty is available in Fedora repos or COPR
distrobox_run bash -c '
    # Try COPR first (most likely source for Ghostty on Fedora)
    if ! command -v ghostty &> /dev/null; then
        sudo dnf copr enable -y pgdev/ghostty 2>/dev/null || true
        sudo dnf install -y ghostty 2>/dev/null || {
            echo ">>> Ghostty not in repos, building from source..."

            # Install build dependencies
            sudo dnf install -y zig gtk4-devel libadwaita-devel

            # Clone and build ghostty
            cd /tmp
            if [ ! -d ghostty ]; then
                git clone https://github.com/ghostty-org/ghostty.git
            fi
            cd ghostty
            zig build -Doptimize=ReleaseFast
            sudo cp zig-out/bin/ghostty /usr/local/bin/
        }
    fi
'

echo ">>> Exporting Ghostty from distrobox to host..."
distrobox enter "$DISTROBOX_NAME" -- distrobox-export --app ghostty 2>/dev/null || \
distrobox enter "$DISTROBOX_NAME" -- distrobox-export --bin /usr/local/bin/ghostty --export-path ~/.local/bin 2>/dev/null || \
distrobox enter "$DISTROBOX_NAME" -- distrobox-export --bin /usr/bin/ghostty --export-path ~/.local/bin 2>/dev/null || \
    echo ">>> Note: Ghostty export may need manual setup"

# Ensure ~/.local/bin is in PATH
mkdir -p ~/.local/bin

# -----------------------------------------------------------------------------
# Install Node.js via nvm inside distrobox
# -----------------------------------------------------------------------------

echo ">>> Installing nvm and Node.js inside distrobox..."
distrobox_run bash -c '
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    fi

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Install latest LTS Node.js
    nvm install --lts
    nvm use --lts

    # Install global npm packages
    npm install -g typescript ts-node prettier eslint
'

# -----------------------------------------------------------------------------
# Install Rust via rustup inside distrobox
# -----------------------------------------------------------------------------

echo ">>> Installing Rust inside distrobox..."
distrobox_run bash -c '
    if ! command -v rustc &> /dev/null; then
        curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi

    source "$HOME/.cargo/env"

    # Install lsd via cargo
    cargo install lsd
'

# -----------------------------------------------------------------------------
# Install Git Credential Manager inside distrobox
# -----------------------------------------------------------------------------

echo ">>> Installing Git Credential Manager inside distrobox..."
distrobox_run bash -c '
    # Download and install GCM
    GCM_VERSION="2.4.1"
    curl -sL "https://github.com/git-ecosystem/git-credential-manager/releases/download/v${GCM_VERSION}/gcm-linux_amd64.${GCM_VERSION}.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/git-credential-manager /usr/local/bin/
    git-credential-manager configure
'

# -----------------------------------------------------------------------------
# Wallpaper and Ghostty shaders (userspace - on host)
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
# Fonts (userspace - on host)
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
# Oh-My-Zsh and plugins inside distrobox
# -----------------------------------------------------------------------------

# This works fine since all of the zsh config is under $HOME
echo ">>> Installing Oh-My-Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
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

echo ">>> Installing Powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# -----------------------------------------------------------------------------
# Symlink dotfiles (on host - shared with distrobox via home mount)
# -----------------------------------------------------------------------------

echo ">>> Linking dotfiles..."

# zshrc
make_link ~/repos/dotfiles/zsh/.zshrc ~/.zshrc

# ghostty config
mkdir -p ~/.config/ghostty
make_link ~/repos/dotfiles/ghostty/.config/ghostty/config ~/.config/ghostty/config

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
# Export useful binaries from distrobox to host
# -----------------------------------------------------------------------------

echo ">>> Exporting CLI tools from distrobox to host..."

# Export commonly used CLI tools so they're accessible on the host
for tool in nvim tmux fzf rg bat lsd neofetch; do
    distrobox enter "$DISTROBOX_NAME" -- distrobox-export --bin "/usr/bin/$tool" --export-path ~/.local/bin 2>/dev/null || true
done

# Export cargo-installed tools
distrobox enter "$DISTROBOX_NAME" -- distrobox-export --bin "$HOME/.cargo/bin/lsd" --export-path ~/.local/bin 2>/dev/null || true

# -----------------------------------------------------------------------------
# Final notes
# -----------------------------------------------------------------------------

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Distrobox '$DISTROBOX_NAME' is ready with all development tools."
echo ""
echo "Usage:"
echo "  - Enter the box:           distrobox enter $DISTROBOX_NAME"
echo "  - Run commands in box:     distrobox enter $DISTROBOX_NAME -- <command>"
echo "  - Ghostty should be available on host via ~/.local/bin/ghostty"
echo ""
echo "Post-setup tasks:"
echo "  1. Add ~/.local/bin to your PATH if not already"
echo "  2. Change default shell to zsh inside distrobox:"
echo "     distrobox enter $DISTROBOX_NAME -- chsh -s /bin/zsh"
echo "  3. Remap Caps Lock: System Settings > Keyboard > Advanced"
echo "  4. VSCode is already installed - configure fonts:"
echo '     "editor.fontFamily": "Comic Shanns Mono"'
echo '     "terminal.integrated.fontFamily": "CaskaydiaCove Nerd Font Mono"'
echo ""

# Show off if neofetch is exported
if [ -x ~/.local/bin/neofetch ]; then
    ~/.local/bin/neofetch
elif command_exists neofetch; then
    neofetch
fi
