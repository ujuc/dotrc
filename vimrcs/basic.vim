" General
syntax on

" Get out of vi compatible mode
set nocompatible

" Turn on modeline
set modeline

" Wirte on make/shell commands
set autowrite

" Set undo
set undofile
set undodir=$HOME/.vim/vimundo
set nowb
set noswapfile

" Turn on the wild menu
set wildmode=list:longest,full

" Show tabline
set showtabline=2

" Show cmd
set showcmd

" Tab
set softtabstop=4
set shiftround
set cindent
set autoindent

" Linebreak on 500 char
set lbr
set tw=500

" Treat long lines as break
map j gj
map k gk

" Source the vimrc file after saving it
autocmd BufWritePost $MYVIMRC PlugClean

let &colorcolumn="51,80,120,".join(range(150,999),",")
highlight ColorColumn ctermbg=235 guibg=#2c2d27

" Use ESC to exit, and use C-J and C-K to move
func! s:unite_sttings()
    nmap <buffer> <ESC> <plug>(unite_exit)
    imap <buffer> <ESC> <plug>(unite_exit)
    imap <buffer> <C-J> <Plug>(unite_select_next_line)
    imap <buffer> <C-K> <Plug>(unite_select_previous_line)
endfunc

