call plug#begin('~/.vim/plugged')

"""""
" UI
"""""
" Hyperfocus writing
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'

"""""""""
" enhancement
"""""""""
" NERD commenter
Plug 'scrooloose/nerdcommenter'

" Unod tree
Plug 'mbbill/undotree'

" Multiple line select
Plug 'terryma/vim-multiple-cursors'

"""""
" Navigation
"""""
" Search engine
Plug 'Shougo/denite.nvim'

" NERD tree
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'

Plug 'christoomey/vim-tmux-navigator'

"""""
" Language
"""""

" Go
Plug 'fatih/vim-go'

" csv
Plug 'chrisbra/csv.vim'

" Presenting
Plug 'sotte/presenting.vim'

" auto pairs
Plug 'jiangmiao/auto-pairs'

call plug#end()
