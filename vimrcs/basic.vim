"
" General
"

" Get out of vi compatible mode
set nocompatible 

" Enable filetype
filetype plugin indent on 

" Increase the lines of history
set history=1000 

" Turn on modeline
set modeline 

" Set autoread when a file is changed from the outside
set autoread 

" Wirte on make/shell commands
set autowrite

" Set nobackup
set nobackup

" Set undo
set undofile
set nowb
set noswapfile

" Set utf-8 encoding
set encoding=utf-8

" Change the mapleader
let mapleader='\'
let g:mapleader='\'

" Fast saving
nmap <leader>w :w!<cr>

" No sound on errors
set noerrorbells
set novisualbell
set t_vb=

" Set 7 lines to the cursor
set so=7

" Turn on the wild menu
set wildmenu
set wildmode=list:longest,full

" Set title
set title
set titlestring=%t%(\ %m%)%(\ (%{expand('%:p:h')})%)%(\ %a%)

" Set tabline
set showtabline=2

" Set up tab labels
set guitablabel=%m%N:%t[%{tabpagewinnr(v:lnum)}]
set tabline=%!MyTabLine()
function! MyTabLine()
	let s = ''
	let t = tabpagenr()
	let i = 1
	while i<=tabpagenr('$')
		let buflist = tabpagebuflist(i)
		let winnr = tabpagewinnr(i)
		let s.=(i==t ? '%#TabLineSel#' : '%#TabLine#')
		let s.='%'.i.'T'
		let s.=' '
		let bufnr = buflist[winnr-1]
		let file = bufname(bufnr)
		let buftype = getbufvar(bufnr, 'buftype')
		let m = ''
		if getbufvar(bufnr, '&modified')
			let m = '[+]'
		endif
		if buftype == 'nofile'
			if file =~ '\/.'
				let file = substitute(file, '.*\/\ze.', '', '')
			endif
		else
			let file = fnamemodify(file, ':p:t')
		endif
		if file == ''
			let file='[No Nmae]'
		endif
		let s.=m
		let s.=i.';'
		let s.=file
		let s.='['.winnr.']'
		let s.=' '
		let i = i+1
	endwhile
	let s.='%T%#TabLineFile#%='
	let s.=(tabpagenr('$')>1 ? '%999XX' : 'X')
	return s
endfunction

" Always show current position
set ru

" Height of the command bar
set cmdheight=2

" A buffer becomes hideen when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Mouse enable
if has ('mouse')
	set mouse=a
endif

" Avoids hit enter
set shortmess=at

" Show cmd
set showcmd

" Lines to scroll when cursor leaves screen
set scrolljump=5

" Minimum lines to keep above and below cursor
set scrolloff=3

" Minimum number of columns to scroll horizontally
set sidescroll=1

" Minimal number of screen columns to keep away from cursor
set sidescrolloff=10

" Show matching barkets/parenthesis
set showmatch
set matchtime=2

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browers
set incsearch

" Don't redraw while executing macros
set lazyredraw

" For regular expressions turn magic on
set magic

" How many tenths of a second to blink when matching brackets
set mat=2

" Set UI
set list " Show these tabs and spaces and so on
set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮ " Change listchars
set linebreak " Wrap long lines at a blank
set showbreak=↪  " Change wrap line break
set fillchars=diff:⣿,vert:│ " Change fillchars
augroup trailing " Only show trailing whitespace when not in insert mode
	autocmd!
	autocmd InsertEnter * :set listchars-=trail:⌴
	autocmd InsertLeave * :set listchars+=trail:⌴
augroup END

syntax enable
"colorscheme 

" Use Unix as the standard file type
set ffs=unix,dos,mac

"
" Text tab
"
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs
set smarttab

" 1 tab == 4 space
set shiftwidth=4
set tabstop=4
set softtabstop=4
set shiftround
set cindent
set autoindent

" Linebreak on 500 characters
set lbr
set tw=500

set list
set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮
set linebreak
set showbreak=↪
set fillchars=diff:⣿,vert:│
augroup trailing
    autocmd!
    autocmd InsertEnter * :set listchars-=trail:⌴
    autocmd InsertLeave * :set listchars+=trail:⌴
augroup END

"
" Search
"

set ignorecase " Case insensitive search
set smartcase " Case sensitive when uc present
set hlsearch " Highlight search terms
set incsearch " Find as you type search
set gdefault " turn on g flag

" Use sane regexes
nnoremap / /\v
vnoremap / /\v
cnoremap s/ s/\v
nnoremap ? ?\v
vnoremap ? ?\v
cnoremap s? s?\v

" Keep search matches in the middle of the window
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap * *zzzv
nnoremap # #zzzv
nnoremap g* g*zzzv
nnoremap g# g#zzzv

" Visual search mappings
function! s:VSetSearch()
    let temp=@@
    normal! gvy
    let @/='\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@=temp
endfunction
vnoremap * :<C-U>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-U>call <SID>VSetSearch()<CR>??<CR>

" Use ,Space to toggle the highlight search
nnoremap <Leader><Space> :set hlsearch!<CR>

" Moving
"

" Treat long lines as break
map j gj
map k gk

" Map <space> to / (search) add Ctrl-<Space> to ?
map <space> /
map <c-space> ?

" Disable highlight when <leader>cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Close the current buffer
map <leader>bd :Bclase<cr>

" Close all the buffers
map <leader>ba :bufdo bd<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <leader>tl :exe "tabn ".g:lasttab<cr>
au TabLeave * let g:lasttab = tabpagenr()

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
    set switchbuf=useopen,usetab,newtab
    set stal=2
catch
endtry

"
" Editting mappings
"

" Remap VIM 0 to first non-blank character
map 0 ^

" Move a line of text using ALT+[jk] or Comand+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-<cr>`>my`<mzgv`yo`z

if has("mac") || has("macunix")
    nmap <D-j> <M-j>
    nmap <D-k> <M-k>
    vmap <D-j> <M-j>
    vmap <D-k> <M-k>
endif

" Delete trailing white space on save, useful for Python and CoffeScript
func! DeleteTrailingWS()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()

"
" Spell checking
"
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

"
" Vim setting
"

" Source the vimrc file after saving it
autocmd BufWritePost $MYVIMRC source $MYVIMRC
autocmd BufWritePost $MYVIMRC PlugClean

" Fast edit the .vimrc file using ,x
nnoremap <leader>x :tabedit $MYVIMRC<CR>

