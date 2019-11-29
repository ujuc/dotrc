call plug#begin('~/.vim/plugged')

"""""
" UI
"""""

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" seoul256
Plug 'junegunn/seoul256.vim'

" Grov box
Plug 'morhetz/gruvbox'

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

" fzf
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

"""""
" Language
"""""

" Go
Plug 'fatih/vim-go'

" Docker
Plug 'ekalinin/dockerfile.vim'
Plug 'docker/docker'

" csv
Plug 'chrisbra/csv.vim'

" Presenting
Plug 'sotte/presenting.vim'

" PHP
Plug 'stanangeloff/php.vim'

" auto pairs
Plug 'jiangmiao/auto-pairs'

call plug#end()
