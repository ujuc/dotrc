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
" Unod tree
Plug 'mbbill/undotree'
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
" Easy motion
Plug 'Lokaltog/vim-easymotion'
" Tag bar
Plug 'majutsushi/tagbar'
" Search engine
Plug 'Shougo/denite.nvim'

"""""""""
" Navigation
"""""""""
" NERD tree tabs
Plug 'jistr/vim-nerdtree-tabs'
" Tmux panes
Plug 'mhinz/vim-tmuxify'

"""""""""
" Git
"""""""""
" Gitk clone
Plug 'gregsexton/gitv'

"""""""""
" Language
"""""""""
" Rails
Plug 'tpope/vim-rails'
" Language Support
Plug 'sheerun/vim-polyglot'
" Python
Plug 'davidhalter/jedi-vim'
" Presenting
Plug 'sotte/presenting.vim'
" sort python imports
Plug 'fisadev/vim-isort'
" Typescript
Plug 'leafgarland/typescript-vim'

call plug#end()
