#!/bin/bash

# macOS Dev Setup Script
# ======================
# Sets up a development environment on macOS.
# Mirrors the CachyOS setup: zsh/p10k/nvim/tmux/ghostty/etc.
#
# First:
#   cd ~
#   git clone https://github.com/markzuber/dotfiles
# Then run: ~/dotfiles/scripts/mac_config.sh

set -e

echo "=== macOS Dev Setup ==="
echo ""

DOTFILES_DIR="$HOME/dotfiles"

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

command_exists() {
    command -v "$1" &>/dev/null
}

make_link() {
    local target="$1"
    local link_name="$2"
    local link_dir
    link_dir="$(dirname "$link_name")"
    mkdir -p "$link_dir"
    if [ -L "$link_name" ]; then
        ln -sf "$target" "$link_name"
    elif [ -e "$link_name" ]; then
        rm -rf "$link_name"
        ln -s "$target" "$link_name"
    else
        ln -s "$target" "$link_name"
    fi
}

brew_install() {
    local pkg="$1"
    if brew list --formula "$pkg" &>/dev/null 2>&1; then
        echo ">>> $pkg already installed"
    else
        echo ">>> Installing $pkg..."
        brew install "$pkg"
    fi
}

brew_cask_install() {
    local pkg="$1"
    if brew list --cask "$pkg" &>/dev/null 2>&1; then
        echo ">>> $pkg (cask) already installed"
    else
        echo ">>> Installing $pkg (cask)..."
        brew install --cask "$pkg"
    fi
}

# -----------------------------------------------------------------------------
# Xcode Command Line Tools
# -----------------------------------------------------------------------------

echo ">>> Ensuring Xcode Command Line Tools are installed..."
if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    echo ">>> Waiting for Xcode CLT install to complete..."
    until xcode-select -p &>/dev/null; do sleep 5; done
else
    echo ">>> Xcode CLT already installed"
fi

# -----------------------------------------------------------------------------
# Homebrew
# -----------------------------------------------------------------------------

if ! command_exists brew; then
    echo ">>> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for this session (Apple Silicon vs Intel)
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo ">>> Homebrew already installed"
    brew update
fi

# -----------------------------------------------------------------------------
# CLI tools via Homebrew
# -----------------------------------------------------------------------------

echo ">>> Installing CLI tools..."

BREW_PACKAGES=(
    git
    git-lfs
    git-delta
    neovim
    tmux
    fzf
    ripgrep
    bat
    lsd
    eza
    fd
    fastfetch
    wget
    cmake
    luarocks
    node
    python@3.13
    lazygit
    gh
    jq
    htop
    zoxide
    television
    stow
    mas
    tree
    pstree
    figlet
    cowsay
    lolcat
    fortune
    speedtest-cli
)

for pkg in "${BREW_PACKAGES[@]}"; do
    brew_install "$pkg"
done

# Enable fzf shell integration
echo ">>> Setting up fzf shell integration..."
"$(brew --prefix)/opt/fzf/install" --all --no-fish --no-update-rc 2>/dev/null || true

# -----------------------------------------------------------------------------
# Apps via Homebrew Cask
# -----------------------------------------------------------------------------

echo ">>> Installing apps..."

BREW_CASKS=(
    ghostty
    iterm2
    discord
    github
    google-chrome
    logitech-g-hub
    notion
    raycast
    rectangle
    signal
    spotify
    visual-studio-code
    git-credential-manager
)

for cask in "${BREW_CASKS[@]}"; do
    brew_cask_install "$cask"
done

# -----------------------------------------------------------------------------
# nvm and Node.js
# -----------------------------------------------------------------------------

echo ">>> Installing nvm..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
    echo ">>> nvm already installed"
fi

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command_exists node; then
    echo ">>> Installing Node.js LTS via nvm..."
    nvm install --lts
    nvm use --lts
else
    echo ">>> Node.js already installed: $(node --version)"
fi

echo ">>> Installing global npm packages..."
NPM_GLOBALS=(typescript ts-node prettier eslint)
for pkg in "${NPM_GLOBALS[@]}"; do
    if ! npm list -g "$pkg" &>/dev/null; then
        npm install -g "$pkg"
    else
        echo ">>> npm package $pkg already installed"
    fi
done

# -----------------------------------------------------------------------------
# Rust via rustup
# -----------------------------------------------------------------------------

echo ">>> Installing Rust..."
if ! command_exists rustc; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo ">>> Rust already installed: $(rustc --version)"
fi
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# -----------------------------------------------------------------------------
# Git credentials (macOS Keychain)
# -----------------------------------------------------------------------------

echo ">>> Configuring Git credentials (osxkeychain)..."
git config --file ~/.gitconfig-local credential.helper osxkeychain

# -----------------------------------------------------------------------------
# Fonts
# -----------------------------------------------------------------------------

echo ">>> Installing fonts..."
mkdir -p ~/Library/Fonts

if [ -f "$DOTFILES_DIR/fonts/FiraCode.zip" ]; then
    unzip -o "$DOTFILES_DIR/fonts/FiraCode.zip" -d ~/Library/Fonts/
fi
if [ -f "$DOTFILES_DIR/fonts/CascadiaCode.zip" ]; then
    unzip -o "$DOTFILES_DIR/fonts/CascadiaCode.zip" -d ~/Library/Fonts/
fi
if [ -f "$DOTFILES_DIR/fonts/comic-shanns-mono-v1.3.0.zip" ]; then
    unzip -o "$DOTFILES_DIR/fonts/comic-shanns-mono-v1.3.0.zip" -d ~/Library/Fonts/
fi

# -----------------------------------------------------------------------------
# Oh-My-Zsh
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
make_link "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc

# p10k
make_link "$DOTFILES_DIR/p10k/.p10k.zsh" ~/.p10k.zsh

# nvim
make_link "$DOTFILES_DIR/nvim/.config/nvim" ~/.config/nvim

# tmux
make_link "$DOTFILES_DIR/tmux/.tmux.conf" ~/.tmux.conf

# editorconfig
make_link "$DOTFILES_DIR/editorconfig/.editorconfig" ~/.editorconfig

# gitconfig
make_link "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig

# ghostty config
make_link "$DOTFILES_DIR/ghostty/.config/ghostty/config" ~/.config/ghostty/config

# VSCode settings (macOS path differs from Linux)
echo ">>> Linking VSCode settings..."
VSCODE_SETTINGS_SRC="$DOTFILES_DIR/vscode/settings.json"
make_link "$VSCODE_SETTINGS_SRC" "$HOME/Library/Application Support/Code/User/settings.json"
make_link "$VSCODE_SETTINGS_SRC" "$HOME/Library/Application Support/Code - Insiders/User/settings.json"

# macOS keyboard shortcuts (Home/End key bindings)
echo ">>> Installing macOS key bindings..."
mkdir -p ~/Library/KeyBindings
cp "$DOTFILES_DIR/macos/DefaultKeyBinding.dict" ~/Library/KeyBindings/DefaultKeyBinding.dict

# iTerm2 preferences
echo ">>> Configuring iTerm2..."
ITERM_PLIST="$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist"
if [ -f "$ITERM_PLIST" ]; then
    # Tell iTerm2 to load prefs from the dotfiles directory
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm2"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    echo ">>> iTerm2 configured to load prefs from $DOTFILES_DIR/iterm2"
fi

# -----------------------------------------------------------------------------
# VSCode Extensions
# -----------------------------------------------------------------------------

echo ">>> Installing VSCode extensions..."
VSCODE_EXTENSIONS=(
    "rust-lang.rust-analyzer"
    "PKief.material-icon-theme"
    "PKief.material-product-icons"
)
for ext in "${VSCODE_EXTENSIONS[@]}"; do
    if ! code --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
        code --install-extension "$ext" 2>/dev/null || echo ">>> Could not install $ext (VSCode may not be in PATH yet)"
    else
        echo ">>> Extension $ext already installed"
    fi
done

# -----------------------------------------------------------------------------
# Caps Lock → Ctrl (via hidutil + LaunchAgent for persistence)
# -----------------------------------------------------------------------------

echo ">>> Remapping Caps Lock to Ctrl..."
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$LAUNCH_AGENTS_DIR/com.user.hidutil.capslock2ctrl.plist"
mkdir -p "$LAUNCH_AGENTS_DIR"

cat > "$PLIST_PATH" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.hidutil.capslock2ctrl</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

launchctl load "$PLIST_PATH" 2>/dev/null || true
/usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}' || true
echo ">>> Caps Lock remapped to Ctrl (persists via LaunchAgent)"

# -----------------------------------------------------------------------------
# macOS system defaults
# -----------------------------------------------------------------------------

echo ">>> Applying macOS system defaults..."

# Finder: show hidden files
defaults write com.apple.finder AppleShowAllFiles YES
# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Disable press-and-hold accent menu (enables key repeat instead)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Fast key repeat rate (lower = faster)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Disable smart quotes (annoying in terminals/code editors)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Dock: left side, no auto-hide, no recent apps
defaults write com.apple.dock orientation -string left
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock show-recents -bool false

# Restart affected apps
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

# -----------------------------------------------------------------------------
# Repos directory
# -----------------------------------------------------------------------------

echo ">>> Setting up repos directory..."
mkdir -p ~/repos

# -----------------------------------------------------------------------------
# Final notes
# -----------------------------------------------------------------------------

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Installed tools:"
echo "  - CLI: git, neovim, tmux, fzf, ripgrep, bat, lsd, eza, lazygit, gh, tv"
echo "  - Languages: Node.js (via nvm), Rust (via rustup)"
echo "  - Apps: Ghostty, iTerm2, VSCode, Discord, Chrome, GitHub Desktop,"
echo "          Logitech G Hub, Notion, Raycast, Rectangle, Signal, Spotify"
echo ""
echo "Post-setup tasks:"
echo "  1. Restart terminal (or open Ghostty) for shell changes to take effect"
echo "  2. Configure Powerlevel10k: p10k configure"
echo "  3. Caps Lock is remapped to Ctrl (via LaunchAgent, active now)"
echo "  4. VSCode font settings:"
echo '     "editor.fontFamily": "Comic Shanns Mono"'
echo '     "terminal.integrated.fontFamily": "CaskaydiaCove Nerd Font Mono"'
echo "  5. If Rectangle or Raycast prompt for accessibility permissions, grant them"
echo "     in System Settings > Privacy & Security > Accessibility"
echo ""

if command_exists fastfetch; then
    fastfetch
fi
