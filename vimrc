" vim: set foldmethod=marker foldlevel=0 nomodeline:
" ----------------------------------------------------------------------
" Plugin using vim-plug
" ----------------------------------------------------------------------
call plug#begin('$HOME/.vim/plugged')

Plug 'morhetz/gruvbox'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" fzf
Plug 'junegunn/fzf.vim'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'jiangmiao/auto-pairs'

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

Plug 'chrisbra/vim-diff-enhanced'

Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'
Plug 'mhinz/vim-startify'

call plug#end()

" ----------------------------------------------------------------------
" Basic
" ----------------------------------------------------------------------

let s:darwin = has('mac')

" General
syntax on

let mapleader=","

set encoding=utf-8
set autoread
set backspace=indent,eol,start
set incsearch
set autowrite
set magic
set noswapfile
set cursorline
set cursorcolumn
set nocp
set tw=500
set mouse-=a

" 한국어 매핑
set langmap=ㅁㅠㅊㅇㄷㄹㅎㅗㅑㅓㅏㅣㅡㅜㅐㅔㅂㄱㄴㅅㅕㅍㅈㅌㅛㅋ;abcdefghijklmnopqrstuvwxyz

" 움직이는 방향으로 7줄 남겨두고 움직이도록
set so=7

" Search
set smartcase
set ignorecase
set hlsearch
set incsearch

" Undo
set undofile
set undodir=$HOME/.vim/vimundo
set nowb

" Wild menu
set wildmode=full
set wildmenu
set wildignorecase

" Show component
set showtabline=2
set showcmd

" Tab - All space
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set softtabstop=4

" Indent
set shiftround
set cindent
set autoindent
set smartindent
set wrap

" Line break
set linebreak
set showbreak=+++\ 

" 공간 구분
set list listchars=tab:»\ ,trail:·,extends:>,precedes:<

" 영어 단어 체크
set spell spelllang=en_us

" column check
set colorcolumn=51,73,81,121
highlight ColorColumn ctermbg=8

" Source the vimrc file after saving it
autocmd BufWritePost $MYVIMRC PlugClean

" ----------------------------------------------------------------------
" Theme
" ----------------------------------------------------------------------
set background=dark
colorscheme gruvbox

" ----------------------------------------------------------------------
" Airline
" ----------------------------------------------------------------------
let g:airline#extenstions#tabline#formatter = 'unique_tail_improved'
let g:airline_theme = 'gruvbox'
let g:airline_powerline_fonts = 1

" ----------------------------------------------------------------------
" File Type
" ----------------------------------------------------------------------
autocmd FileType ruby setlocal ts=2 sts=2 sw=2
autocmd FileType html setlocal ts=4 sts=4 sw=4
autocmd FileType javascript setlocal ts=2 sts=2 sw=2
autocmd FileType markdown setlocal ts=2 sts=2 sw=2
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd FileType gitcommit set tw=72

" ----------------------------------------------------------------------
" Key map
" ----------------------------------------------------------------------
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
