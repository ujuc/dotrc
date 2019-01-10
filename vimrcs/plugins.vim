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

Plug 'terryma/vim-multiple-cursors'

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
Plug 'w0rp/ale'

" Go
Plug 'fatih/vim-go'

" Markdown
Plug 'plasticboy/vim-markdown'

" JSON
Plug 'elzr/vim-json'

" Docker
Plug 'ekalinin/dockerfile.vim'

" csv
Plug 'chrisbra/csv.vim'

" YCM
Plug 'Valloric/YouCompleteMe', { 'do': 'python3 ./install.py --go-completer --ts-completer --clang-completer' }

" Presenting
Plug 'sotte/presenting.vim'

" dev icons
" Need nerd font
Plug 'ryanoasis/vim-devicons'

call plug#end()
