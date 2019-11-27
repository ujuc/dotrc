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


