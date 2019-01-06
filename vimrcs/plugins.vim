call plug#begin('~/.vim/plugged')

"""""
" UI
"""""

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" seoul256
Plug 'junegunn/seoul256.vim'

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

" Splitjoin
Plug 'AndrewRadev/splitjoin.vim'

" Text object
Plug 'wellle/targets.vim'

Plug 'tpope/vim-sensible'

" Create better diffs
Plug 'chrisbra/vim-diff-enhanced'

"""""
" Navigation
"""""

" Tag bar
" Need ctag
Plug 'majutsushi/tagbar'

" Search engine
Plug 'Shougo/denite.nvim'

" NERD tree
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'

Plug 'christoomey/vim-tmux-navigator'

" File explorer
Plug 'Shougo/vimfiler.vim'

" fzf
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

"""""
" Git
"""""

" Gita
Plug 'lambdalisue/vim-gita'

" vim-gitgutter
Plug 'airblade/vim-gitgutter'

"""""
" Language
"""""
" Language Support
Plug 'scrooloose/syntastic'
Plug 'sheerun/vim-polyglot'
Plug 'Chiel92/vim-autoformat'
Plug 'w0rp/ale'

" Rails
Plug 'tpope/vim-rails'

" Python
Plug 'davidhalter/jedi-vim'

" sort python imports
" Need isort 
Plug 'fisadev/vim-isort'


"""""
" File type
"""""

" csv
Plug 'chrisbra/csv.vim'

"""""
" Present
"""""

" Presenting
Plug 'sotte/presenting.vim'

" dev icons
" Need nerd font
Plug 'ryanoasis/vim-devicons'

call plug#end()
