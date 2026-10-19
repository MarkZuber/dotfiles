#!/bin/bash

# macOS Dev Setup Script
# ======================
# Sets up a development environment on macOS.
#
# First:
#   cd ~
#   git clone https://github.com/markzuber/dotfiles
# Then run: ~/dotfiles/scripts/machine_setup.sh (or this script directly)

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
    starship
    atuin
    direnv
    mise
    glow
    xh
    sshs
    mas
    tree
    pstree
    figlet
    cowsay
    lolcat
    fortune
    dockutil
    tree-sitter-cli
    uv
    awscli
    glab
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
    logitech-g-hub
    notion
    raycast
    rectangle
    signal
    spotify
    visual-studio-code
    git-credential-manager
    zoom
    caffeine
    scroll-reverser
)

for cask in "${BREW_CASKS[@]}"; do
    brew_cask_install "$cask"
done

# -----------------------------------------------------------------------------
# Claude CLI
# -----------------------------------------------------------------------------
echo ">>> Installing claude..."
curl -fsSL https://claude.ai/install.sh | bash

# -----------------------------------------------------------------------------
# Node, Python, Go and global npm CLIs via mise (~/.config/mise/config.toml, linked below)
# -----------------------------------------------------------------------------

echo ">>> Installing mise-managed tools..."
# The config is linked later by link-dotfiles.sh, so point mise at the repo copy for this run.
MISE_GLOBAL_CONFIG_FILE="$DOTFILES_DIR/mise/.config/mise/config.toml" mise install

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
# rustaceanvim (nvim) expects rust-analyzer on PATH from the toolchain, not from Mason.
rustup component add rust-analyzer clippy rustfmt

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
# The font Ghostty and VS Code are actually set to ("ComicShanns Nerd Font").
cp "$DOTFILES_DIR/fonts/ComicShannsNerdFont-Regular.ttf" ~/Library/Fonts/

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

# Completions only (.zshrc adds its src/ to fpath); not loaded as an oh-my-zsh plugin.
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
else
    echo ">>> zsh-completions already installed"
fi

# -----------------------------------------------------------------------------
# tmux plugin manager (.tmux.conf runs ~/.tmux/plugins/tpm/tpm)
# -----------------------------------------------------------------------------

echo ">>> Installing tpm..."
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo ">>> tpm already installed"
fi

# -----------------------------------------------------------------------------
# Symlink dotfiles
# -----------------------------------------------------------------------------

echo ">>> Linking dotfiles..."
# Every link (shell, editors, terminals, git, VS Code, Claude Code, herdr, iTerm2 prefs) is made
# by scripts/link-dotfiles.sh; --replace sets aside config that installers above already wrote.
"$DOTFILES_DIR/scripts/link-dotfiles.sh" --replace

# -----------------------------------------------------------------------------
# Shell tool data that lives outside the repo
# -----------------------------------------------------------------------------

echo ">>> Fetching television community channels..."
tv update-channels || true

echo ">>> Importing zsh history into atuin..."
[ -f "$HOME/.zsh_history" ] && atuin import zsh || true

if [ -f "$HOME/.z" ]; then
    echo ">>> Importing z directory history into zoxide..."
    zoxide import --from z "$HOME/.z" || true
fi

echo ">>> Installing gh-dash..."
gh extension list 2>/dev/null | grep -q dlvhdr/gh-dash || gh extension install dlvhdr/gh-dash || true

# -----------------------------------------------------------------------------
# Touch ID for sudo. Asks first, and writes /etc/pam.d/sudo_local, which survives macOS
# updates; /etc/pam.d/sudo itself is reset by them and should never be edited.
# -----------------------------------------------------------------------------

if grep -qs '^auth[[:space:]]*sufficient[[:space:]]*pam_tid.so' /etc/pam.d/sudo_local; then
    echo ">>> Touch ID for sudo already enabled"
else
    read -r -p ">>> Enable Touch ID for sudo? [y/N] " reply
    if [[ "$reply" =~ ^[Yy]$ ]]; then
        echo "auth       sufficient     pam_tid.so" | sudo tee -a /etc/pam.d/sudo_local >/dev/null
        echo ">>> Touch ID for sudo enabled"
    fi
fi

# macOS keyboard shortcuts (Home/End key bindings)
echo ">>> Installing macOS key bindings..."
mkdir -p ~/Library/KeyBindings
cp "$DOTFILES_DIR/macos/DefaultKeyBinding.dict" ~/Library/KeyBindings/DefaultKeyBinding.dict


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
# defaults write com.apple.dock show-recents -bool false

# Restart Finder for hidden files setting
killall Finder 2>/dev/null || true

# -----------------------------------------------------------------------------
# Dock contents
# -----------------------------------------------------------------------------

echo ">>> Configuring Dock apps..."

# dockutil --remove all --no-restart 2>/dev/null || true

DOCK_APPS=(
    "/Applications/Google Chrome.app"
    "/System/Applications/System Settings.app"
    "/System/Applications/Notes.app"
    "/System/Applications/Messages.app"
    "/Applications/Signal.app"
    "/Applications/Notion.app"
    "/Applications/Discord.app"
    "/System/Applications/Photos.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/Ghostty.app"
    "/Applications/Spotify.app"
    "/System/Applications/Music.app"
)

# for app in "${DOCK_APPS[@]}"; do
#     if [ -d "$app" ]; then
#         dockutil --add "$app" --no-restart 2>/dev/null || true
#     fi
# done

# killall Dock 2>/dev/null || true

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
echo "  - CLI: git, neovim, tmux, fzf, ripgrep, bat, lsd, lazygit, gh, tv, starship, atuin,"
echo "         zoxide, direnv, glow, xh, sshs"
echo "  - Languages: Node.js, Python, Go (via mise), Rust (via rustup)"
echo "  - Apps: Ghostty, iTerm2, VSCode, Discord, Chrome, GitHub Desktop,"
echo "          Logitech G Hub, Notion, Raycast, Rectangle, Signal, Spotify"
echo ""
echo "Post-setup tasks:"
echo "  1. Restart terminal (or open Ghostty) for shell changes to take effect"
echo "  2. Open nvim once: LazyVim installs plugins, Mason installs language servers"
echo "  3. Caps Lock is remapped to Ctrl (via LaunchAgent, active now)"
echo '  4. Fonts: Ghostty and VS Code use "ComicShanns Nerd Font" (installed above)'
echo "  5. If Rectangle or Raycast prompt for accessibility permissions, grant them"
echo "     in System Settings > Privacy & Security > Accessibility"
echo "  6. Optional: 'atuin register' to sync shell history between machines"
echo ""
echo "Key bindings and commands: $DOTFILES_DIR/CHEATSHEET.md"
echo ""

if command_exists fastfetch; then
    fastfetch
fi
