call plug#begin('~/.vim/plugged')

"""""""
" UI
"""""""
" Status line
Plug 'bling/vim-airline'
" Buffer line
Plug 'bling/vim-bufferline'
" Indent guides
Plug 'nathanaelkane/vim-indent-guides'
" Distraction-free
Plug 'junegunn/goyo.vim'
" Hyperfocus-writing
Plug 'junegunn/limelight.vim'
" sourcerer
Plug 'xero/sourcerer.vim'

""""""""
" Document
""""""""
" Take Notes in rst
Plug 'Rykka/riv.vim'


"""""""""
" Lint
"""""""""
" Flake8 plugin for Vim
Plug 'nvie/vim-flake8'
" Simple, easy-to-use VIM alignment
Plug 'junegunn/vim-easy-align'
" ruby reek for vim
Plug 'rainerborene/vim-reek'


"""""""""
" enhancement
"""""""""
" Enhance integration with the terminal
Plug 'wincent/terminus'
" Closing of quotes
Plug 'Raimondi/delimitMate'
" NERD commenter
Plug 'scrooloose/nerdcommenter'
" Abolish
Plug 'tpope/vim-abolish'
" Speed dating
Plug 'tpope/vim-speeddating'
" Repeat
Plug 'tpope/vim-repeat'
" Unod tree
Plug 'mbbill/undotree'
" Surround
Plug 'tpope/vim-surround'
" Tabular
Plug 'godlygeek/tabular'
" Splitjoin
Plug 'AndrewRadev/splitjoin.vim'
" Vim pasta
Plug 'sickill/vim-pasta'
" Helper
Plug 'Keithbsmiley/investigate.vim'
" Hard mode
Plug 'wikitopian/hardmode'
" Text object
Plug 'wellle/targets.vim'
" Resize windows
Plug 'roman/golden-ratio'
" Create better diffs
Plug 'chrisbra/vim-diff-enhanced'


"""""""""
" Moving
"""""""""
" Pairs of mappings
Plug 'tpope/vim-unimpaired'
" Easy motion
Plug 'Lokaltog/vim-easymotion'
" Camel case motion
Plug 'bkad/CamelCaseMotion'
" Tag bar
Plug 'majutsushi/tagbar'
" Match it
Plug 'edsono/vim-matchit'
" Search engine
Plug 'Shougo/unite.vim'
" Unite outline
Plug 'Shougo/unite-outline'


"""""""""
" Navigation
"""""""""
" NERD tree
Plug 'scrooloose/nerdtree'
" NERD tree tabs
Plug 'jistr/vim-nerdtree-tabs'
" Tmux panes
Plug 'mhinz/vim-tmuxify'


"""""""""
" Compile
"""""""""
" Syntax checking
Plug 'scrooloose/syntastic'
" Single compile
Plug 'xuhdev/SingleCompile'


"""""""""
" Git
"""""""""
" Git wrapper
Plug 'tpope/vim-fugitive'
" Gitk clone
Plug 'gregsexton/gitv'
" Git diff sign
Plug 'airblade/vim-gitgutter'


"""""""""
" Language
"""""""""
" Golang
Plug 'fatih/vim-go'
" Rails
Plug 'tpope/vim-rails'
" Language Support
Plug 'sheerun/vim-polyglot'
" Python
Plug 'davidhalter/jedi-vim'
" Presenting
Plug 'sotte/presenting.vim'
" Markdown runtime files
Plug 'tpope/vim-markdown'


call plug#end()
