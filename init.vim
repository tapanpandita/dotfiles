"""""""""""""""""""""
""Tapan's neo-vimrc""
"""""""""""""""""""""
call plug#begin('~/.local/share/nvim/plugged')

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'sbdchd/neoformat'
Plug 'davidhalter/jedi-vim'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'neomake/neomake'
Plug 'tmhedberg/SimpylFold'
Plug 'morhetz/gruvbox'
Plug 'vim-scripts/xoria256.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'rafi/awesome-vim-colorschemes'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'

call plug#end()


" Change the mapleader from \ to ,
let mapleader=","
let maplocalleader="\\"


" General defaults
set tabstop=4     " a tab is four spaces
set backspace=indent,eol,start
                  " allow backspacing over everything in insert mode
set autoindent    " always set autoindenting on
set copyindent    " copy the previous indentation on autoindenting
set shiftwidth=4  " number of spaces to use for autoindenting
set expandtab     " use appropriate number of spaces when tabbing
set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch     " set show matching parenthesis
set ignorecase    " ignore case when searching
set smartcase     " ignore case if search pattern is all lowercase, case-sensitive otherwise
set smarttab      " insert tabs on the start of a line according to shiftwidth, not tabstop
set hlsearch      " highlight search terms
set incsearch     " show search matches as you type
set history=1000  " remember more commands and search history
set undolevels=1000
                  " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class,*\/migrations\/*
set title         " change the terminal's title
set nobackup      " don't write a backup file
set ruler         " show the cursor position all the time
set pastetoggle=<F2>
                  " toggle paste mode
"set nonumber      " dont show line numbers, for python mode
set number
"set wrap          " wrap long lines, for python mode
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
                  " highlight whitespace
set viminfo='20,\"50
                  " Tell vim to remember certain things when we exit
set hidden        " allow buffers to be hidden
set laststatus=2 " Always display the statusline in all windows
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set autoread
"set mouse=nicr    " mouse scroll in terminal vim
"nnoremap ; :     " Saves keystrokes
"set autochdir    " automatically changes directory to file in buffer
"set mouse=a      " Enable mouse support in console if you are into weird shit


"Unhighlight search
nmap <silent> <Leader>/ :nohlsearch <CR>


"Toggle showing line numbers
nmap <f3> :set number! number?<cr>


" Colorscheme
if (has("termguicolors"))
  set termguicolors
endif
silent! colorscheme xoria256
"colorscheme ayu


" Deoplete
let g:deoplete#enable_at_startup = 1
" Use tab to toggle through autocomplete window
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
call deoplete#custom#option('omni_patterns', {
\ 'go': '[^. *\t]\.\w*',
\})


" Neoformat
let g:neoformat_python_black = {
    \ 'exe': 'black',
    \ 'stdin': 1,
    \ 'args': ['-q', '-'],
    \ }
let g:neoformat_enabled_python = ['black']
let g:neoformat_enabled_go = ['gofmt', 'goimports']

augroup fmt
  autocmd!
  autocmd BufWritePre * undojoin | Neoformat
augroup END


" Jedi
" disable autocompletion, because we use deoplete for completion
let g:jedi#completions_enabled = 0

" open the go-to function in split, not another buffer
let g:jedi#use_splits_not_buffers = "right"


" Neomake
let g:neomake_python_enabled_makers = ['pylint']
let g:neomake_go_enabled_makers = ['golint', 'govet', 'errcheck']
call neomake#configure#automake('nrwi', 500)


" Nerdtree
"nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Start NERDTree. If a file is specified, move the cursor to its window.
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif
" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif


" FZF
nnoremap <silent> <leader>t :Files<CR>
nnoremap <silent> <leader>f :Ag<CR>


" ViM Airline settings
let g:airline_powerline_fonts=1
let g:airline_theme='badwolf'


" Set default file encoding to unicode
if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=utf-8,latin1
endif


" Buffer shortcuts
" toggle recent buffers
map ,3 :b#<CR>
map ,n :bn<CR>
map ,p :bp<CR>


" Need to figure tab stuff some day
"tabs
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tk  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnew<Space>
nnoremap tm  :tabm<Space>
nnoremap td  :tabclose<CR>


" Use system clipboard (only works if compiled with +x)
if $TMUX == ''
    set clipboard+=unnamed
endif


" Window shortcuts
nnoremap ,h <C-w>h
nnoremap ,j <C-w>j
nnoremap ,k <C-w>k
nnoremap ,l <C-w>l


" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
map N Nzz
map n nzz


" Cool tab completion stuff while entering commands
set wildmenu
set wildmode=list:longest,full


"show current command in bottom line
set showcmd


"folds
set foldmethod=indent
set foldcolumn=0
set foldlevel=0
set foldenable


"save files if you forgot to sudo
cmap w!! %!sudo tee > /dev/null %


" Arrow keys are evil!
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>


"Magically move up and down in the same wrapped line!
nnoremap j gj
nnoremap k gk


"Reload vimrc
nnoremap <leader>sv :source $MYVIMRC<CR>

" Goyo and limelight
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!
