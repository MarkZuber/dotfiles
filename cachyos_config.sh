#!/bin/bash

# CachyOS (Arch-based) Dev Setup Script
# ======================================
# This script sets up a development environment on CachyOS.
# All installations happen natively using pacman and yay (AUR helper).
#
# First thing to do is:
# mkdir -p ~/repos
# cd ~/repos
# git clone https://github.com/markzuber/dotfiles
# then run ~/repos/dotfiles/cachyos_config.sh

set -e

echo "=== CachyOS Dev Setup ==="
echo ""

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

command_exists() {
    command -v "$1" &> /dev/null
}

# Check if a package is installed
package_installed() {
    pacman -Qi "$1" &> /dev/null
}

# Install package if not already installed
install_if_missing() {
    local pkg="$1"
    if ! package_installed "$pkg"; then
        echo ">>> Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg"
    else
        echo ">>> $pkg already installed"
    fi
}

# Install AUR package if not already installed (using yay)
install_aur_if_missing() {
    local pkg="$1"
    if ! package_installed "$pkg"; then
        echo ">>> Installing $pkg from AUR..."
        yay -S --noconfirm "$pkg"
    else
        echo ">>> $pkg already installed"
    fi
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

# -----------------------------------------------------------------------------
# System update
# -----------------------------------------------------------------------------

echo ">>> Updating system packages..."
sudo pacman -Syu --noconfirm

# -----------------------------------------------------------------------------
# Install yay (AUR helper) if not present
# -----------------------------------------------------------------------------

echo ">>> Ensuring yay (AUR helper) is installed..."
if ! command_exists yay; then
    echo ">>> Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    if [ -d yay ]; then
        rm -rf yay
    fi
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
else
    echo ">>> yay already installed"
fi

# -----------------------------------------------------------------------------
# Install packages via pacman
# -----------------------------------------------------------------------------

echo ">>> Installing development packages..."

PACMAN_PACKAGES=(
    git
    zsh
    neovim
    tmux
    fzf
    ripgrep
    bat
    lsd
    fastfetch
    unzip
    curl
    wget
    gcc
    make
    cmake
    openssl
    fontconfig
    freetype2
    libxcb
    libxkbcommon
    pkg-config
    base-devel
    steam
    alsa-scarlett-gui
    lutris
    luarocks 
    luacheck 
    nodejs 
    npm 
    python-pip
    python-pynvim
)

for pkg in "${PACMAN_PACKAGES[@]}"; do
    install_if_missing "$pkg"
done

# -----------------------------------------------------------------------------
# Install Ghostty
# -----------------------------------------------------------------------------

echo ">>> Installing Ghostty..."
install_aur_if_missing ghostty

# -----------------------------------------------------------------------------
# Install Node.js via nvm
# -----------------------------------------------------------------------------

echo ">>> Installing nvm and Node.js..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
    echo ">>> nvm already installed"
fi

# Source nvm and install Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command_exists node; then
    echo ">>> Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
else
    echo ">>> Node.js already installed: $(node --version)"
fi

# Install global npm packages
echo ">>> Installing global npm packages..."
NPM_GLOBALS=(typescript ts-node prettier eslint)
for pkg in "${NPM_GLOBALS[@]}"; do
    if ! npm list -g "$pkg" &> /dev/null; then
        npm install -g "$pkg"
    else
        echo ">>> npm package $pkg already installed"
    fi
done

# -----------------------------------------------------------------------------
# Install Rust via rustup
# -----------------------------------------------------------------------------

echo ">>> Installing Rust..."
if ! command_exists rustc; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo ">>> Rust already installed: $(rustc --version)"
fi

# Ensure cargo env is sourced
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# -----------------------------------------------------------------------------
# Install Git Credential Manager
# -----------------------------------------------------------------------------

echo ">>> Installing Git Credential Manager..."
if ! command_exists git-credential-manager; then
    install_aur_if_missing git-credential-manager-core-bin
    git-credential-manager configure 2>/dev/null || true
else
    echo ">>> Git Credential Manager already installed"
fi

# -----------------------------------------------------------------------------
# Wallpaper and Ghostty shaders
# -----------------------------------------------------------------------------

echo ">>> Setting up repos directory..."
mkdir -p ~/repos
cd ~/repos

if [ ! -d ~/repos/wallpaper ]; then
    git clone https://github.com/markzuber/wallpaper
else
    echo ">>> wallpaper repo already cloned"
fi

if [ ! -d ~/repos/ghostty-shaders ]; then
    git clone --depth 1 https://github.com/hackr-sh/ghostty-shaders
else
    echo ">>> ghostty-shaders repo already cloned"
fi

mkdir -p ~/.config/ghostty/ghostty-shaders
cp ~/repos/ghostty-shaders/*.glsl ~/.config/ghostty/ghostty-shaders/

cd ~

# -----------------------------------------------------------------------------
# Fonts
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
# Set zsh as default shell
# -----------------------------------------------------------------------------

# echo ">>> Setting zsh as default shell..."
# if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
#     chsh -s /bin/zsh 2>/dev/null || \
#     sudo usermod -s /bin/zsh "$USER" 2>/dev/null || \
#     echo ">>> Note: Run 'chsh -s /bin/zsh' manually to change shell"
# else
#     echo ">>> zsh is already the default shell"
# fi

# -----------------------------------------------------------------------------
# Oh-My-Zsh and plugins
# -----------------------------------------------------------------------------

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
else
    echo ">>> zsh-autosuggestions already installed"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo ">>> zsh-syntax-highlighting already installed"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
    git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
else
    echo ">>> fzf-tab already installed"
fi

echo ">>> Installing Powerlevel10k..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo ">>> Powerlevel10k already installed"
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

# VSCode settings - native installs
echo ">>> Linking VSCode settings..."
VSCODE_SETTINGS_SRC=~/repos/dotfiles/vscode/settings.json

# Native VSCode Stable
mkdir -p ~/.config/Code/User
make_link "$VSCODE_SETTINGS_SRC" ~/.config/Code/User/settings.json

# Native VSCode Insiders
mkdir -p ~/.config/"Code - Insiders"/User
make_link "$VSCODE_SETTINGS_SRC" ~/.config/"Code - Insiders"/User/settings.json

# -----------------------------------------------------------------------------
# Install VSCode
# -----------------------------------------------------------------------------

echo ">>> Installing VSCode..."
install_aur_if_missing visual-studio-code-bin

# -----------------------------------------------------------------------------
# Install Google Chrome
# -----------------------------------------------------------------------------

echo ">>> Installing Google Chrome..."
install_aur_if_missing google-chrome

# -----------------------------------------------------------------------------
# Install VSCode Extensions
# -----------------------------------------------------------------------------

echo ">>> Installing VSCode extensions..."

VSCODE_EXTENSIONS=(
    "rust-lang.rust-analyzer"
    "PKief.material-icon-theme"
    "PKief.material-product-icons"
)

for ext in "${VSCODE_EXTENSIONS[@]}"; do
    if ! code --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
        echo ">>> Installing extension: $ext"
        code --install-extension "$ext" 2>/dev/null || \
            echo ">>> Could not install $ext - VSCode may not be available yet"
    else
        echo ">>> Extension $ext already installed"
    fi
done

# -----------------------------------------------------------------------------
# KDE Settings: Caps Lock as Ctrl (if KDE is detected)
# -----------------------------------------------------------------------------

if [ -n "$KDE_SESSION_VERSION" ] || command_exists plasmashell; then
    echo ">>> Configuring Caps Lock as Ctrl in KDE..."

    mkdir -p ~/.config

    if command_exists kwriteconfig6; then
        kwriteconfig6 --file ~/.config/kxkbrc --group Layout --key Options "caps:ctrl_modifier"
    elif command_exists kwriteconfig5; then
        kwriteconfig5 --file ~/.config/kxkbrc --group Layout --key Options "caps:ctrl_modifier"
    else
        if [ -f ~/.config/kxkbrc ]; then
            if grep -q "^\[Layout\]" ~/.config/kxkbrc; then
                if grep -q "^Options=" ~/.config/kxkbrc; then
                    sed -i 's/^Options=.*/Options=caps:ctrl_modifier/' ~/.config/kxkbrc
                else
                    sed -i '/^\[Layout\]/a Options=caps:ctrl_modifier' ~/.config/kxkbrc
                fi
            else
                echo -e "\n[Layout]\nOptions=caps:ctrl_modifier" >> ~/.config/kxkbrc
            fi
        else
            cat > ~/.config/kxkbrc << 'EOF'
[Layout]
Options=caps:ctrl_modifier
EOF
        fi
    fi

    echo ">>> Caps Lock will act as Ctrl after re-login or restart"

    # -----------------------------------------------------------------------------
    # KDE Custom Shortcut: Ctrl+Super+T for Ghostty
    # -----------------------------------------------------------------------------

    echo ">>> Adding Ctrl+Super+T shortcut for Ghostty..."

    SHORTCUTS_DIR="$HOME/.config"
    KHOTKEYS_FILE="$SHORTCUTS_DIR/khotkeysrc"
    GHOSTTY_CMD="ghostty"

    mkdir -p "$SHORTCUTS_DIR"

    if [ -f "$KHOTKEYS_FILE" ] && grep -q "Ghostty Terminal" "$KHOTKEYS_FILE"; then
        echo ">>> Ghostty shortcut already configured"
    else
        if [ -f "$KHOTKEYS_FILE" ]; then
            NEXT_NUM=$(grep -oP '^\[Data_\K[0-9]+' "$KHOTKEYS_FILE" 2>/dev/null | sort -n | tail -1)
            NEXT_NUM=$((NEXT_NUM + 1))
            CURRENT_COUNT=$(grep -oP '^DataCount=\K[0-9]+' "$KHOTKEYS_FILE" 2>/dev/null || echo "0")
            NEW_COUNT=$((CURRENT_COUNT + 1))
            sed -i "s/^DataCount=.*/DataCount=$NEW_COUNT/" "$KHOTKEYS_FILE"
        else
            NEXT_NUM=1
            echo -e "[Data]\nDataCount=1\n" > "$KHOTKEYS_FILE"
        fi

        cat >> "$KHOTKEYS_FILE" << EOF

[Data_${NEXT_NUM}]
Comment=Launch Ghostty Terminal
Enabled=true
Name=Ghostty Terminal
Type=SIMPLE_ACTION_DATA

[Data_${NEXT_NUM}Actions]
ActionsCount=1

[Data_${NEXT_NUM}Actions0]
CommandURL=$GHOSTTY_CMD
Type=COMMAND_URL

[Data_${NEXT_NUM}Conditions]
ConditionsCount=0

[Data_${NEXT_NUM}Triggers]
TriggersCount=1

[Data_${NEXT_NUM}Triggers0]
Key=Ctrl+Meta+T
Type=SHORTCUT
UUID={$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen 2>/dev/null || echo "ghostty-shortcut-$(date +%s)")}
EOF

        echo ">>> Added Ctrl+Super+T shortcut for Ghostty"
    fi

    if command_exists qdbus6; then
        qdbus6 org.kde.kglobalaccel /kglobalaccel reloadConfig 2>/dev/null || true
    elif command_exists qdbus; then
        qdbus org.kde.kglobalaccel /kglobalaccel reloadConfig 2>/dev/null || true
    fi

    echo ">>> KDE shortcut may require re-login to take effect"
else
    echo ">>> KDE not detected, skipping KDE-specific configuration"
fi

# -----------------------------------------------------------------------------
# Final notes
# -----------------------------------------------------------------------------

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Installed tools:"
echo "  - CLI: git, zsh, neovim, tmux, fzf, ripgrep, bat, lsd, fastfetch"
echo "  - Languages: Node.js (via nvm), Rust (via rustup)"
echo "  - Apps: VSCode, Google Chrome, Ghostty"
echo ""
echo "Post-setup tasks:"
echo "  1. Log out and back in for shell change to take effect"
echo "  2. Configure Powerlevel10k: p10k configure"
echo "  3. VSCode font settings:"
echo '     "editor.fontFamily": "Comic Shanns Mono"'
echo '     "terminal.integrated.fontFamily": "CaskaydiaCove Nerd Font Mono"'
echo ""

# Show off with fastfetch
if command_exists fastfetch; then
    fastfetch
fi
