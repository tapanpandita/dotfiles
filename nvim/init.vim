"""""""""""""""""""""
""Tapan's neo-vimrc""
"""""""""""""""""""""
call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'sheerun/vim-polyglot'
Plug 'preservim/nerdcommenter'
Plug 'Mofiqul/vscode.nvim'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'bronson/vim-trailing-whitespace'
Plug 'folke/trouble.nvim'
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" lsp
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" Statusline
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'

" Snippets
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'rafamadriz/friendly-snippets'

" Telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }

call plug#end()


lua require 'cmp_config'
lua require 'lsp_config'
lua require 'config'


set completeopt=menu,menuone,noselect


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
set number
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
                  " highlight whitespace
set viminfo='20,\"50
                  " Tell vim to remember certain things when we exit
set hidden        " allow buffers to be hidden
set laststatus=2 " Always display the statusline in all windows
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set autoread


"Unhighlight search
nmap <silent> <Leader>/ :nohlsearch <CR>


"Toggle showing line numbers
nmap <f3> :set number! number?<cr>


" Colorscheme
if (has("termguicolors"))
  set termguicolors
endif
silent! colorscheme vscode


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


" Tabs vs Spaces
autocmd FileType cpp,python,html,javascript,javascript.jsx setlocal tabstop=4 shiftwidth=4 expandtab
autocmd FileType c,scala,java,ruby setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType go setlocal noexpandtab

" Escape ansi codes for terminal filetypes
autocmd FileType terminal :AnsiEsc


" Telescope
" Find files using Telescope command-line sugar.
nnoremap <leader>t <cmd>Telescope find_files<CR>
nnoremap <leader>f <cmd>Telescope grep_string search="" only_sort_text=true shorten_path=true<CR>
nnoremap <leader>p <cmd>Telescope live_grep<CR>
