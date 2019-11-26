" General
syntax on

let mapleader="," " 기본 설정 단축키 
set encoding=utf-8

set autoread

" backspace
set backspace=indent,eol,start

" 7줄 남겨두고 움직이기
set so=7

" 검색
set smartcase	" 대문자가 검색어 문자열에 포함될때는 noignorecase
set ignorecase	" 검색시 대소문자 무시
set hlsearch	" 검색시 하이라이트
set incsearch	" 검색 키워드 입력시 점진 검색

" Write on make/shell commands
set autowrite

" 매크로 실행중엔 새롭개 그리지 않음
set lazyredraw

" 규식이형 마술!
set magic

" Set undo
set undofile
set undodir=$HOME/.vim/vimundo
set nowb
set noswapfile

" Turn on the wild menu
set wildmode=full
set wildmenu
set wildignorecase

" Show tab line
set showtabline=2

" Show cmd
set showcmd

" Tab
" 탭 대신 공백 사용
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set softtabstop=4

set shiftround
set cindent
set autoindent
set smartindent
set wrap

" Linebreak on 500 char
set lbr
set tw=500

set spell spelllang=en_us
set complete+=kspell

" Source the vimrc file after saving it
autocmd BufWritePost $MYVIMRC PlugClean

let &colorcolumn="51,72,80,120,".join(range(150,999),",")
highlight ColorColumn ctermbg=235 guibg=#2c2d27

" space를 닷으로 구분한다.
set list listchars=tab:·\ ,trail:·,extends:>,precedes:<

