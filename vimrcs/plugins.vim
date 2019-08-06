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

" Create better diffs
Plug 'chrisbra/vim-diff-enhanced'

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
" Git
"""""
Plug 'tpope/vim-fugitive'

" vim-gitgutter
Plug 'airblade/vim-gitgutter'

"""""
" Language
"""""
" Language Support
Plug 'sheerun/vim-polyglot'
Plug 'Chiel92/vim-autoformat'
Plug 'dense-analysis/ale'

" Go
Plug 'fatih/vim-go'

" Markdown
Plug 'plasticboy/vim-markdown'

" Docker
Plug 'ekalinin/dockerfile.vim'
Plug 'docker/docker'

" csv
Plug 'chrisbra/csv.vim'

" Presenting
Plug 'sotte/presenting.vim'

" dev icons
" Need nerd font
Plug 'ryanoasis/vim-devicons'

" neo coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" PHP
Plug 'stanangeloff/php.vim'

call plug#end()
