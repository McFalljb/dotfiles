" Enable syntax highlighting
syntax on

" Set color scheme (you may need to install this)
colorscheme desert

" Enable file type detection and plugin/indent info
filetype plugin indent on

" Show line numbers
set number

" Enable relative line numbers
set relativenumber

" Highlight current line
set cursorline

" Show matching brackets
set showmatch

" Enable mouse support
set mouse=a

" Set tab width to 4 spaces
set tabstop=4
set shiftwidth=4
set expandtab

" Auto-indent
set autoindent
set smartindent

" Highlight search results
set hlsearch

" Incremental search (search as you type)
set incsearch

" Ignore case when searching
set ignorecase
set smartcase

" Enable code folding
set foldmethod=indent
set foldlevel=99

" Show a ruler at 80 characters
set colorcolumn=80

" Enable auto-completion
set wildmenu
set wildmode=longest,list,full

" Enable persistent undo
set undofile
set undodir=~/.vim/undodir

" Highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Auto-remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Enable clipboard support (might require vim-gtk or vim-gnome)
set clipboard=unnamedplus

" Remap common operations
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a
nnoremap <C-q> :q<CR>
nnoremap <C-f> /
nnoremap <C-h> :%s/

" Split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" NERDTree settings (you need to install NERDTree plugin)
" map <C-n> :NERDTreeToggle<CR>
" autocmd vimenter * NERDTree
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Enable status line
set laststatus=2

" Custom status line
set statusline=%F%m%r%h%w%=(%{&ff}/%Y)\ (line\ %l\/%L,\ col\ %c)\

" Enable backspace in insert mode
set backspace=indent,eol,start

" Disable swap files
set noswapfile

" Set encoding
set encoding=utf-8

" Enable line wrapping
set wrap

" Show command in bottom bar
set showcmd

" Highlight matching parenthesis
set showmatch

" Load filetype-specific indent files
filetype indent on

" Visual autocomplete for command menu
set wildmenu

" Redraw only when we need to
set lazyredraw

" Enable auto-reload of files changed outside vim
set autoread

" Set updatetime to 100ms for faster git gutter updates
set updatetime=100
