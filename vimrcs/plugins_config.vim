""""""
" UI
""""""

" Airline
let g:airline_powerline_fonts = 1
let g:airline_theme='wombat'

" Indnet guide
let g:indent_guides_enalbe_on_vim_startup = 1
let g:indent_guides_default_mapping = 0
let g:indent_guides_exclude_filetypes = ['hlep', 'nerdtree', 'markdown']
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1

" Goyo limelight
func! GoyoBefore()
    Limelight
endfunc
func! GoyoAfter()
    Limlight!
endfunc
let g:goyo_callbacks = [function('GoyoBefore'), function('GoyoAfter')]


"""""
" enhancement
"""""

" NERD Commenter
let NERDCommentWholetLinesInVMode = 2
let NERDSpaceDelims = 1
let NERDRemoveExtraSpaces = 1
" Mpa \<Space> to commenting
func! IsWhiteLine()
    if (getline('.')=~'^$')
        let oldlinenumber = line('.')
        call NERDComment('n', 'sexy')
        if (line('.') == oldlinenumber)
            call NERDComment('n', 'append')
            normal! x
        else
            normal! k
            startinsert!
        endif
    else
        normal! A
        call NERDComment('n', 'append')
        normal! x
    endif
endfunc
nnoremap <silent> <LocalLeader><Space> :call IsWhiteLine()<cr>

" Undo tree
nnoremap <leader>u :UndotreeToggle<cr>
let g:undotree_SetFocusWhenToggle = 1

if has("persistent_undo")
    set undodir=~/.undodir/
    set undofile
endif

" investingate.vim
nnoremap K :call investigate#Investigate()<cr>


"""""
" Navigation
"""""

" Tag bar
nnoremap <leader>t :TagbarToggle<cr>
let g:tagbar_autofocus = 1
let g:tagbar_expand = 1
let g:tagbar_foldlevel = 2
let g:tagbar_autoshowtag = 1

" NERDTreeTab
nnoremap <leader>nt :NERDTreeTabsToggle<cr>
"nnoremap <leader>f :NERDTreeFind<cr>
"let NERDTreeChDirMode = 2
"let NERDTreeShowBookmarks = 1
"let NERDTreeShowHidden = 1
"let NERDTreeShowLineNumbers = 1
"let NERDTreeDirArrows = 1
"let g:nerdtree_tabs_open_on_gui_startup = 0


"""""
" Language
"""""

" isort
let g:vim_isort_map = '<C-i>'
