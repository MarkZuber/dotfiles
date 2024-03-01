#!/bin/sh

# To Install
# chrome
# vscode
# spotify
# messenger
# chrome
# iterm2
# caffiene
# logitech g-hub
# mos
# notion

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install --cask rectangle
brew install rustup-init tree-sitter neovim ripgrep fzf eza cowsay fortune figlet bat lazygit lolcat lsd stow
brew install youtube-dl jq htop git-lfs pstree wget pkg-config git-credential-manager

# Maybe just get nvm instead
# brew instal node yarn

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# powerlevel 10k -> https://github.com/romkatv/powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# reminder: set ZSH_THEME="powerlevel10k/powerlevel10k" in .zshrc

touch ~/.hushlogin

# tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux

# zsh helpers
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosugestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# bring down dotfiles
git clone https://github.com/markzuber/dotfiles ~/dotfiles

# Specify the preferences directory for iterm2
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/dotfiles/iterm2"
# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true


pushd ~/dotfiles
stow .
# not sure if zsh will stow properly since installing zsh will put it there
popd

# install .net
brew install --cask dotnet

# install rust (quiet)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# todo afterwards manually
# launch nvim and let it configure plugins
