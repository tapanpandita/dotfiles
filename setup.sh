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
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}


## ZSH

function setup_zsh {
    # Install pure prompt
    echo "Installing pure ..."
    brew install pure

    # Install core utils for gnu version of shell commands like ls
    echo "Installing coreutils"
    brew install coreutils

    # Install colors for ls - vivid
    echo "Installing vivid ..."
    brew install vivid

    # Install shell utilities
    echo "Installing fzf, fd, bat and rg"
    brew install fzf fd bat ripgrep
    # setup fzf completion and keybindings
    "$(brew --prefix)/opt/fzf/install" --no-bash --completion --key-bindings --no-update-rc

    # Link zshrc
    # this is in case these is an existing useful zshrc which we want to extend
    # example: on a work laptop
    if ! [ -f "$HOME/.zshrc" ]; then
        # We always want to use the custom zshrc pattern so make a dummy zshrc
        echo "Creating dummy zshrc ..."
        touch "$HOME/.zshrc"
    fi

    if ! [ -L "$HOME/.custom-zshrc.sh" ]; then
        ln -s "$DOTFILES_DIR/zshrc.symlink" "$HOME/.custom-zshrc.sh"
    fi

    if ! grep -q "source $HOME/.custom-zshrc.sh" "$HOME/.zshrc"; then
        echo "source $HOME/.custom-zshrc.sh" >> "$HOME/.zshrc"
    fi

    # Link ripgreprc
    mkdir -p "$HOME/.config"
    if [ -f "$HOME/.config/.ripgreprc" ]; then
        mv "$HOME/.config/.ripgreprc" "$HOME/.config/.ripgreprc.bck"
    else
        echo "Linking ripgreprc..."
        ln -s "$DOTFILES_DIR/ripgreprc.symlink" "$HOME/.config/.ripgreprc"
    fi
}


## PYTHON

function install_python {
    # Install python
    echo "Installing python ..."
    brew install pyenv
    brew install zlib
    export PYENV_ROOT=$HOME/.pyenv
    export PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
    eval "$(pyenv init --path)"
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

## NODE

function install_node {
    # Install nvm
    echo "Installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    # Install node and npm
    nvm install node
    nvm use node
}


## NEOVIM

# Install neovim and dependencies
function install_neovim_and_dependencies {
    echo "Installing neovim and utilities..."
    brew install neovim
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
    mkdir -p "$HOME/.config/nvim/lua"

    # first backup any existing config
    if [ -f "$HOME/.config/nvim/init.vim" ]; then
        mv "$HOME/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim.backup"
    fi

    if [ -f "$HOME/.config/nvim/lua/config.lua" ]; then
        mv "$HOME/.config/nvim/lua/config.lua" "$HOME/.config/nvim/lua/config.lua.backup"
    fi

    if [ -f "$HOME/.config/nvim/lua/lsp_config.lua" ]; then
        mv "$HOME/.config/nvim/lua/lsp_config.lua" "$HOME/.config/nvim/lua/lsp_config.lua.backup"
    fi

    if [ -f "$HOME/.config/nvim/lua/cmp_config.lua" ]; then
        mv "$HOME/.config/nvim/lua/cmp_config.lua" "$HOME/.config/nvim/lua/cmp_config.lua.backup"
    fi

    # then link all the config files
    ln -s "$DOTFILES_DIR/nvim/init.vim" "$HOME/.config/nvim/init.vim"
    ln -s "$DOTFILES_DIR/nvim/lua/config.lua" "$HOME/.config/nvim/lua/config.lua"
    ln -s "$DOTFILES_DIR/nvim/lua/lsp_config.lua" "$HOME/.config/nvim/lua/lsp_config.lua"
    ln -s "$DOTFILES_DIR/nvim/lua/cmp_config.lua" "$HOME/.config/nvim/lua/cmp_config.lua"

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
    if [ -f "$HOME/.gitconfig" ]; then
        mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup"
    fi
    ln -s "$DOTFILES_DIR/gitconfig.symlink" "$HOME/.gitconfig"
}


## TERMINAL

function setup_terminal {
    # Install fira code
    echo "Installing fira code font ..."
    brew tap homebrew/cask-fonts
    brew install --cask font-fira-code-nerd-font

    # Install kitty
    mkdir -p "$HOME/.config/kitty/"
    echo "Installing kitty ..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    echo "Setting up kitty ..."
    if [ -f "$HOME/.config/kitty/kitty.conf" ]; then
        mv "$HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf.backup"
    fi
    if [ -f "$HOME/.config/kitty/launch-actions.conf" ]; then
        mv "$HOME/.config/kitty/launch-actions.conf" "$HOME/.config/kitty/launch-actions.conf.backup"
    fi
    if [ -f "$HOME/.config/kitty/open-actions.conf" ]; then
        mv "$HOME/.config/kitty/open-actions.conf" "$HOME/.config/kitty/open-actions.conf.backup"
    fi
    ln -s "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    ln -s "$DOTFILES_DIR/kitty/launch-actions.conf" "$HOME/.config/kitty/launch-actions.conf"
    ln -s "$DOTFILES_DIR/kitty/open-actions.conf" "$HOME/.config/kitty/open-actions.conf"
}


## UTILITIES

# Install utilities
function install_utilities {
    echo "Installing utilities ..."
    brew install wget
    brew install htop
    brew install --cask rectangle
    brew install --cask the-unarchiver
    brew install --cask stats
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
    install_node
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
