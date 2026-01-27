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
# Set zsh as default shell inside distrobox
# -----------------------------------------------------------------------------

echo ">>> Setting zsh as default shell inside distrobox..."
distrobox_run bash -c '
    if [ "$SHELL" != "/bin/zsh" ]; then
        sudo chsh -s /bin/zsh $(whoami) 2>/dev/null || \
        sudo usermod -s /bin/zsh $(whoami) 2>/dev/null || \
        echo ">>> Note: Could not change shell automatically, run: chsh -s /bin/zsh"
    fi
'

# -----------------------------------------------------------------------------
# Set zsh as default shell on host (Bazzite)
# -----------------------------------------------------------------------------

echo ">>> Setting zsh as default shell on host..."
# On immutable systems, zsh should already be available or we use the distrobox zsh
if command_exists zsh; then
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo ">>> Changing default shell to zsh on host..."
        chsh -s "$(which zsh)" 2>/dev/null || \
        sudo usermod -s "$(which zsh)" "$USER" 2>/dev/null || \
        echo ">>> Note: Run 'chsh -s $(which zsh)' manually to change shell"
    else
        echo ">>> zsh is already the default shell on host"
    fi
else
    echo ">>> zsh not found on host - terminal will use distrobox zsh via ghostty"
fi

# -----------------------------------------------------------------------------
# Oh-My-Zsh and plugins (shared via home mount)
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

# VSCode settings - native installs
echo ">>> Linking VSCode settings..."
VSCODE_SETTINGS_SRC=~/repos/dotfiles/vscode/settings.json

# Native VSCode Stable
mkdir -p ~/.config/Code/User
make_link "$VSCODE_SETTINGS_SRC" ~/.config/Code/User/settings.json

# Native VSCode Insiders
mkdir -p ~/.config/"Code - Insiders"/User
make_link "$VSCODE_SETTINGS_SRC" ~/.config/"Code - Insiders"/User/settings.json

# Flatpak VSCode Stable
mkdir -p ~/.var/app/com.visualstudio.code/config/Code/User
make_link "$VSCODE_SETTINGS_SRC" ~/.var/app/com.visualstudio.code/config/Code/User/settings.json

# Flatpak VSCode Insiders
mkdir -p ~/.var/app/com.visualstudio.code-insiders/config/"Code - Insiders"/User
make_link "$VSCODE_SETTINGS_SRC" ~/.var/app/com.visualstudio.code-insiders/config/"Code - Insiders"/User/settings.json

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
# Install Chrome via Flatpak
# -----------------------------------------------------------------------------

echo ">>> Installing Google Chrome via Flatpak..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.google.Chrome || echo ">>> Chrome may already be installed"

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
    echo ">>> Installing extension: $ext"
    code --install-extension "$ext" 2>/dev/null || \
    flatpak run com.visualstudio.code --install-extension "$ext" 2>/dev/null || \
        echo ">>> Could not install $ext - VSCode may not be available yet"
done

# -----------------------------------------------------------------------------
# KDE Settings: Caps Lock as Ctrl
# -----------------------------------------------------------------------------

echo ">>> Configuring Caps Lock as Ctrl in KDE..."

# KDE stores keyboard settings in kxkbrc
mkdir -p ~/.config

# Set Caps Lock as Ctrl using kwriteconfig6 (KDE 6) or kwriteconfig5 (KDE 5)
if command_exists kwriteconfig6; then
    kwriteconfig6 --file ~/.config/kxkbrc --group Layout --key Options "caps:ctrl_modifier"
elif command_exists kwriteconfig5; then
    kwriteconfig5 --file ~/.config/kxkbrc --group Layout --key Options "caps:ctrl_modifier"
else
    # Fallback: write directly to the config file
    if [ -f ~/.config/kxkbrc ]; then
        # Check if [Layout] section exists
        if grep -q "^\[Layout\]" ~/.config/kxkbrc; then
            # Update or add Options line
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

# KDE custom shortcuts are stored in kglobalshortcutsrc and khotkeysrc
SHORTCUTS_DIR="$HOME/.config"
KHOTKEYS_FILE="$SHORTCUTS_DIR/khotkeysrc"

# Launch ghostty inside the distrobox with zsh shell
GHOSTTY_CMD="distrobox enter $DISTROBOX_NAME -- zsh -c ghostty"

# Create/update khotkeysrc for custom shortcuts
mkdir -p "$SHORTCUTS_DIR"

# Check if khotkeysrc exists and has our shortcut
if [ -f "$KHOTKEYS_FILE" ] && grep -q "Ghostty Terminal" "$KHOTKEYS_FILE"; then
    echo ">>> Ghostty shortcut already configured"
else
    # Find the next available Data group number
    if [ -f "$KHOTKEYS_FILE" ]; then
        NEXT_NUM=$(grep -oP '^\[Data_\K[0-9]+' "$KHOTKEYS_FILE" 2>/dev/null | sort -n | tail -1)
        NEXT_NUM=$((NEXT_NUM + 1))
        # Also increment DataCount
        CURRENT_COUNT=$(grep -oP '^DataCount=\K[0-9]+' "$KHOTKEYS_FILE" 2>/dev/null || echo "0")
        NEW_COUNT=$((CURRENT_COUNT + 1))
        sed -i "s/^DataCount=.*/DataCount=$NEW_COUNT/" "$KHOTKEYS_FILE"
    else
        NEXT_NUM=1
        echo -e "[Data]\nDataCount=1\n" > "$KHOTKEYS_FILE"
    fi

    # Append the new shortcut configuration
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

# Reload KDE shortcuts (if possible)
if command_exists qdbus6; then
    qdbus6 org.kde.kglobalaccel /kglobalaccel reloadConfig 2>/dev/null || true
elif command_exists qdbus; then
    qdbus org.kde.kglobalaccel /kglobalaccel reloadConfig 2>/dev/null || true
fi

echo ">>> KDE shortcut may require re-login to take effect"

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
