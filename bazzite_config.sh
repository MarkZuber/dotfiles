#!/bin/bash

# First thing to do is:
# mkdir -p ~/repos
# cd ~/repos
# git clone https://github.com/markzuber/dotfiles
# then run ~/repos/dotfiles/bazzite_config.sh

# Need to fix (at least on Nobora)
# 1. fix sound (usb plugged in?)
# 2. fix nvim configs (because obviously they're out of date and broken)

sudo dnf update -y
sudo dnf install lsd fzf ripgrep nvim bat tmux neofetch git -y

## git credential manager - need to test this
sudo dnf copr enable matthickford/git-credential-manager -y
sudo dnf install git-credential-manager
git-credential-manager-core configure

mkdir -p ~/repos
cd ~/repos
git clone https://github.com/markzuber/wallpaper

git clone --depth 1 https://github.com/hackr-sh/ghostty-shaders
cd ghostty-shaders
mkdir -p ~/.config/ghostty/ghostty-shaders
cp *.glsl ~/.config/ghostty/ghostty-shaders
cd ~

# install ghostty
sudo dnf copr enable scottames/ghostty
sudo dnf install ghostty

# install vscode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &&
  echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf check-update && sudo dnf install code # or code-insiders

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# install fonts
mkdir -p ~/.local/share/fonts
unzip ~/repos/dotfiles/fonts/FiraCode.zip -d ~/.local/share/fonts/
unzip ~/repos/dotfiles/fonts/CascadiaCode.zip -d ~/.local/share/fonts/
unzip ~/repos/dotfiles/fonts/comic-shanns-mono-v1.3.0.zip -d ~/.local/share/fonts/
fc-cache -fv

# install rust (funky syntax after sh is so we can skip any prompts)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# install zsh / omzsh
sudo dnf install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

# install powerlevel10k (existing config is in the p10k file)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# link dotfiles files to home/.config/etc
rm ~/.zshrc
ln -s ~/repos/repos/dotfiles/zsh/.zshrc ~/.zshrc
mv ~/.config/ghostty/config ~/.config/ghostty/config.bak || true
ln -s ~/repos/dotfiles/ghostty/.config/ghostty/config ~/.config/ghostty/config
mv ~/.p10k.zsh ~/.p10k.zsh.bak || true
ln -s ~/repos/dotfiles/p10k/.p10k.zsh ~/.p10k.zsh

rm ~/.config/nvim || true
ln -s ~/repos/dotfiles/nvim/.config/nvim ~/.config/nvim
# tmux
mv ~/.tmux.conf ~/.tmux.conf.bak || true
ln -s ~/repos/dotfiles/tmux/.tmux.conf ~/.tmux.conf
# editorconfig
ln -s ~/repos/dotfiles/editorconfig/.editorconfig ~/.editorconfig
# gitconfig
mv ~/.gitconfig ~/.gitconfig.bak || true
ln -s ~/repos/dotfiles/git/.gitconfig ~/.gitconfig

# install/configure xone for xbox remote controller
git clone https://github.com/medusalix/xone
cd xone
sudo ./install.sh --release
sudo xone-get-firmware.sh

# show off
neofetch

# THINGS TO DO that I can't automate
# remap capslock
  # system settings / keyboard / advanced (to get to key bindings)
  # Make caps lock act as an additional Crrl modifier
# update vscode settings

# Key ones - if the fonts don't show up, make sure fc-cache -fv has been run
#    "editor.fontFamily": "Comic Shanns Mono",
#    "terminal.integrated.fontFamily":"CaskaydiaCove Nerd Font Mono",
#    "terminal.integrated.fontSize": 14,
#    "editor.fontSize": 16
    
# Install chrome / make default browser

# test this a bit first before automating
# source "${0:a:h}/update_bazzite_wallpaper.sh" "~/repos/wallpaper/01113_different_1920x1200.jpg"


