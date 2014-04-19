CURRENT_DIR=pwd
VIM_COLORS_DIR=$HOME/.vim/colors/
VUNDLE_DIR=$HOME/.vim/bundle/vundle

mkdir -p $VIM_COLORS_DIR
wget http://www.vim.org/scripts/download_script.php\?src_id\=15762 -O $VIM_COLORS_DIR/xoria256.vim

git clone https://github.com/gmarik/vundle.git $VUNDLE_DIR
vim +PluginInstall +qall

cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer
cd CURRENT_DIR
