#!/bin/bash
set -euo pipefail

DOTFILES_DIR=$(pwd)

## BREW

function install_xcode_command_line_tools {
    echo "Checking for xcode command line tools ..."
    if xcode-select -p 1>/dev/null ; then
        echo "Command line tools are already installed"
    else
        echo "Installing xcode command line tools ..."
        # Install command line tools
        xcode-select --install
        # Accept command line tools license
        sudo xcodebuild -license
    fi
}

function install_homebrew {
    # Brew depends on xcode command line tools
    # Check if installed and if not, install
    install_xcode_command_line_tools

    # Install brew
    if which -s brew ; then
        # Brew already installed, update it
        echo "Updating brew ..."
        brew update
    else
        # Install Homebrew
        echo "Installing brew ..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}


## ZSH

function setup_zsh {
    # Install pure prompt
    echo "Installing pure ..."
    brew install pure

    # Install colors for ls - vivid
    echo "Installing vivid ..."
    brew install vivid

    # Link zshrc
    if [ -f ~/.zshrc ]; then
        # this is in case these is an existing useful zshrc which we want to extend
        # example: on a work laptop
        echo "Linking custom zshrc ..."
        if ! [ -L ~/.custom-zshrc.sh ]; then
            ln -s "$DOTFILES_DIR/zshrc.symlink" ~/.custom-zshrc.sh
            echo "source $HOME/.custom-zshrc.sh" >> ~/.zshrc
        fi
    else
        echo "Linking zshrc ..."
        ln -s "$DOTFILES_DIR/zshrc.symlink" ~/.zshrc
    fi
}


## PYTHON

function install_python {
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
}


## NEOVIM

# Install neovim and dependencies
function install_neovim_and_dependencies {
    echo "Installing neovim and utilities..."
    brew install neovim
    brew install fzf
    echo "Check if fzf keybindings need to be installed!"
    brew install ripgrep
    brew install the_silver_searcher
    brew install fd
    brew install shellcheck
    pip install neovim pynvim
    npm i --location=global pyright
    npm i --location=global bash-language-server
    brew install lua
    brew install luarocks
    brew install lua-language-server
}

# Set up neovim
function setup_neovim {
    # Install vim plug
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

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
    ln -s "$DOTFILES_DIR/nvim/init.vim" ~/.config/nvim/init.vim
    ln -s "$DOTFILES_DIR/nvim/lua/config.lua" ~/.config/nvim/lua/config.lua
    ln -s "$DOTFILES_DIR/nvim/lua/lsp_config.lua" ~/.config/nvim/lua/lsp_config.lua
    ln -s "$DOTFILES_DIR/nvim/lua/cmp_config.lua" ~/.config/nvim/lua/cmp_config.lua

    # Install nvim plugins
    echo "Installing neovim plugins ..."
    nvim +PlugInstall +qall
}


## GOLANG

# Install go
function install_golang {
    echo "Installing golang ..."
    mkdir -p "$HOME/go/{bin,src}"
    brew install golang
}


## GIT

# Link gitconfig
function setup_gitconfig {
    echo "Setting up git ..."
    if [ -f ~/.gitconfig ]; then
        mv ~/.gitconfig ~/.gitconfig.backup
    fi
    ln -s "$DOTFILES_DIR/gitconfig.symlink" ~/.gitconfig
}


## TERMINAL

function setup_terminal {
    # Install fira code
    echo "Installing fira code font ..."
    brew tap homebrew/cask-fonts
    brew install --cask font-fira-code-nerd-font

    # Install kitty
    mkdir -p ~/.config/kitty/
    echo "Installing kitty ..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    echo "Setting up kitty ..."
    if [ -f ~/.config/kitty/kitty.conf ]; then
        mv ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf.backup
    fi
    ln -s "$DOTFILES_DIR/kittyconfig.symlink" ~/.config/kitty/kitty.conf
}


## UTILITIES

# Install utilities
function install_utilities {
    echo "Installing utilities ..."
    brew install wget
    brew install htop
    brew install --cask the-unarchiver
    brew install --cask visual-studio-code
}

# Only install on personal laptop
function install_personal_utilities {
    echo "Installing personal utilities ..."
    brew install --cask vlc
    brew install --cask discord
    brew install --cask steam
    brew install --cask epic-games
    brew install --cask google-chrome
    brew install --cask nordvpn
}

all_except_personal=''
personal=''

print_usage() {
  printf "Usage: pass -a to install all packages except personal and -p to install personal packages. pass -ap to install everything"
}

while getopts 'ap' flag; do
  case "${flag}" in
    p) personal='true'
       echo "Installing all packages including personal" ;;
    a) all_except_personal='true'
        echo "Installing all packages except personal" ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [ $all_except_personal = "true" ]; then
    install_homebrew
    setup_zsh
    install_python
    install_neovim_and_dependencies
    setup_neovim
    install_golang
    setup_gitconfig
    setup_terminal
    install_utilities
fi

if [ $personal = "true" ]; then
    install_personal_utilities
fi
