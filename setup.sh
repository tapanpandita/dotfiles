#!/bin/bash
set -euo pipefail

DOTFILES_DIR=`pwd`

## BREW

# Install command line tools
xcode-select -p 1>/dev/null
if [[ $? != 0 ]] ; then
    # Install command line tools
    xcode-select --install
    # Accept command line tools license
    sudo xcodebuild -license
else
    echo "Command line tools are already installed"
fi

# Install brew
which -s brew

if [[ $? != 0 ]] ; then
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    # Update brew
    brew update
fi


## ZSH

# Install oh my zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Link zshrc
if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.backup
fi
ln -s $DOTFILES_DIR/zshrc.symlink ~/.zshrc


## PYTHON

# Install python
brew install pyenv
brew install zlib
pyenv install 3.9.1
pyenv global 3.9.1

# Install poetry
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

# Install python tools
pip install --upgrade pip
pip install ipython jedi black pylint


## NEOVIM

# Install neovim stuff
brew install neovim
brew install fzf
brew install ripgrep
brew install the_silver_searcher
#brew install macvim
pip install neovim pynvim

# Install vim-plug
# For neovim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# For vim
#curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    #https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Link init.vim
if [ -f ~/.config/nvim/init.vim ]; then
    mv ~/.config/nvim/init.vim ~/.config/nvim/init.vim.backup
fi
#if [ -f ~/.vimrc ]; then
    #mv ~/.vimrc ~/.vimrc.backup
#fi
ln -s $DOTFILES_DIR/init.vim ~/.config/nvim/init.vim
#ln -s $DOTFILES_DIR/init.vim ~/.vimrc

# Install nvim plugins
nvim +PlugInstall +qall
#mvim +PlugInstall +qall


## GOLANG

# Install go
mkdir -p $HOME/go/{bin,src}
brew install golang


## GIT

# Link gitconfig
if [ -f ~/.gitconfig ]; then
    mv ~/.gitconfig ~/.gitconfig.backup
fi
ln -s $DOTFILES_DIR/gitconfig.symlink ~/.gitconfig


## TERMINAL

# Install fira code
brew tap homebrew/cask-fonts
brew install --cask font-fira-code


## UTILITIES

# Install utilities
brew install wget
brew install htop

##TODO
# Backup and restore keypairs and server pem files
# SSH Config files
# Wireguard conf file

# Install the following
# Fira Code Font
# Postgres.app
# iterm 2
# Chrome
# Wireguard
# NordVPN
# Steam
# Discord
# VS Code
# The Unarchiver
# VLC
# MS Office
