CURRENT_DIR=pwd
VIM_BASE_DIR=$HOME/.vim
VIM_COLORS_DIR=$VIM_BASE_DIR/colors
VIM_TMP_DIR=$VIM_BASE_DIR/tmp
VIM_BACKUP_DIR=$VIM_BASE_DIR/backup

mkdir -p $VIM_TMP_DIR
mkdir -p $VIM_BACKUP_DIR

mkdir -p $VIM_COLORS_DIR
wget http://www.vim.org/scripts/download_script.php\?src_id\=15762 -O $VIM_COLORS_DIR/xoria256.vim

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer
cd CURRENT_DIR
