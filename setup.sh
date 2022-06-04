#!/bin/bash
set -euo pipefail

DOTFILES_DIR=`pwd`

## BREW

# Install command line tools
echo "Checking for xcode command line tools ..."
xcode-select -p 1>/dev/null
if [[ $? != 0 ]] ; then
    echo "Installing xcode command line tools ..."
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
    echo "Installing brew ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    # Update brew
    echo "Updating brew ..."
    brew update
fi


## ZSH

# Install pure prompt
echo "Installing pure ..."
brew install pure

# Link zshrc
if [ -f ~/.zshrc ]; then
    # this is in case these is an existing useful zshrc which we want to extend
    # example: on a work laptop
    echo "Linking custom zshrc ..."
    if ! [ -L ~/.custom-zshrc.sh ]; then
        ln -s $DOTFILES_DIR/zshrc.symlink ~/.custom-zshrc.sh
        echo "source $HOME/.custom-zshrc.sh" >> ~/.zshrc
    fi
else
    echo "Linking zshrc ..."
    ln -s $DOTFILES_DIR/zshrc.symlink ~/.zshrc
fi


## PYTHON

# Install python
echo "Installing python ..."
brew install pyenv
brew install zlib
pyenv install 3.10.4
pyenv global 3.10.4

# Install poetry
echo "Installing poetry ..."
curl -sSL https://install.python-poetry.org | python3 -

# Install python tools
echo "Installing python tools ..."
pip install --upgrade pip
pip install ipython


## LUA

# Install lua
echo "Setting up lua ..."
brew install lua
brew install luarocks
brew install lua-language-server


## NEOVIM

# Install neovim stuff
echo "Installing neovim and utilities..."
brew install neovim
brew install fzf
echo "Check if fzf keybindings need to be installed!"
# run /usr/local/opt/fzf/install to setup keybindings
brew install ripgrep
brew install the_silver_searcher
brew install fd
pip install neovim pynvim
npm i -g pyright

# Install vim-plug
# For neovim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# For vim
#curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    #https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Link neovim config
echo "linking neovim config ..."
mkdir -p ~/.config/nvim/lua

# first backup any existing config
if [ -f ~/.config/nvim/init.vim ]; then
    mv ~/.config/nvim/init.vim ~/.config/nvim/init.vim.backup
fi

if [ -f ~/.config/nvim/lua/config.lua ]; then
    mv ~/.config/nvim/lua/config.lua ~/.config/nvim/lua/config.lua.backup
fi

if [ -f ~/.config/nvim/lua/lsp_config.lua ]; then
    mv ~/.config/nvim/lua/lsp_config.lua ~/.config/nvim/lua/lsp_config.lua.backup
fi

if [ -f ~/.config/nvim/lua/cmp_config.lua ]; then
    mv ~/.config/nvim/lua/cmp_config.lua ~/.config/nvim/lua/cmp_config.lua.backup
fi

# then link all the config files
ln -s $DOTFILES_DIR/nvim/init.vim ~/.config/nvim/init.vim
ln -s $DOTFILES_DIR/nvim/lua/config.lua ~/.config/nvim/lua/config.lua
ln -s $DOTFILES_DIR/nvim/lua/lsp_config.lua ~/.config/nvim/lua/lsp_config.lua
ln -s $DOTFILES_DIR/nvim/lua/cmp_config.lua ~/.config/nvim/lua/cmp_config.lua

# Install nvim plugins
echo "Installing neovim plugins ..."
nvim +PlugInstall +qall


## GOLANG

# Install go
echo "Installing golang ..."
mkdir -p $HOME/go/{bin,src}
brew install golang


## GIT

# Link gitconfig
echo "Setup git ..."
if [ -f ~/.gitconfig ]; then
    mv ~/.gitconfig ~/.gitconfig.backup
fi
ln -s $DOTFILES_DIR/gitconfig.symlink ~/.gitconfig


## TERMINAL

# Install fira code
echo "Installing fira code font ..."
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font


## UTILITIES

# Install utilities
echo "Installing utilities ..."
brew install wget
brew install htop

##TODO
# Backup and restore keypairs and server pem files
# SSH Config files
# Wireguard conf file

# Install the following
# iterm 2
# Chrome
# Wireguard
# NordVPN
# Steam
# Discord
# VS Code
# The Unarchiver
# VLC
