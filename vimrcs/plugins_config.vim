"""""""""
" UI Plugin
"""""""""

" Indent Guides
let g:indent_guides_enable_on_vim_startup = 1
"let g:indent_guides_guide_size = 1
let g:indent_guides_default_mapping = 0
let g:indent_guides_exclude_filetypes = ['help', 'nerdtree', 'markdown']

" Goyo & Limelight
func! GoyoBefore()
    Limelight
endfunc
func! GoyoAfter()
    Limlight!
endfunc
let g:goyo_callbacks = [function('GoyoBefore'), function('GoyoAfter')]

" Airline
let g:airline_powerline_fonts = 1

"""""""""
" Enhancement
"""""""""

" DelimiMate
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1
let delimitMate_balance_matchpairs = 1

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

" investingate.vim
nnoremap K :call investigate#Investigate()<cr>


"""""""""
" Move
"""""""""

" Tag bar
nnoremap <leader>t :TagbarToggle<cr>
let g:tagbar_autofocus = 1
let g:tagbar_expand = 1
let g:tagbar_foldlevel = 2
let g:tagbar_autoshowtag = 1

" Matchit
nmap <Tab> %
vmap <Tab> %

" Unite
let g:unite_data_directory = $HOME . '/.vim/cache/unite'
let g:unite_source_history_yank_enable = 1
let g:unite_source_rec_max_cache_files = 100
let g:unite_prompt='» '

" Use ESC to exit, and use C-J and C-K to move
func! s:unite_sttings()
    nmap <buffer> <ESC> <plug>(unite_exit)
    imap <buffer> <ESC> <plug>(unite_exit)
    imap <buffer> <C-J> <Plug>(unite_select_next_line)
    imap <buffer> <C-K> <Plug>(unite_select_previous_line)
endfunc
autocmd filetype unite call s:unite_settings()
nnoremap <silent> <Space>f :<C-U>Unite -start-insert -auto-resize -buffer-name=files file_rec/async<cr><C-U>
nnoremap <silent> <Space>y :<C-U>Unite -start-insert -buffer-name=yanks history/yank<cr>
nnoremap <silent> <Space>l :<C-U>Unite -start-insert -auto-resize -buffer-name=line line<cr>
nnoremap <silent> <Space>o :<C-U>Unite -auto-resize -buffer-name=outline outline<cr>
nnoremap <silent> <Space>b :<C-U>Unite -quick-match buffer<cr>
nnoremap <silent> <Space>t :<C-U>Unite -quick-match tab<cr>
nnoremap <silent> <Space>/ :<C-U>Unite -auto-resize -buffer-name-search grep:.<cr>

"""""""""
" Navigate
"""""""""

" NERD Tree
nnoremap <leader>d :NERDTreeTabsToggle<cr>
nnoremap <leader>f :NERDTreeFind<cr>
let NERDTreeChDirMode = 2
let NERDTreeShowBookmarks = 1
let NERDTreeShowHidden = 1
let NERDTreeShowLineNumbers = 1
let NERDTreeDirArrows = 1
let g:nerdtree_tabs_open_on_gui_startup = 0

"""""""""
" Compile
"""""""""

" Syntastic
let g:syntastic_check_on_open = 1
let g:syntastic_aggregate_errors = 1
let g:syntastic_auto_jump = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_error_symbol = '✗'
let g:syntastic_style_error_symbol = '✠'
let g:syntastic_warning_symbol = '∆'
let g:syntastic_style_warning_symbol = '≈'

" Singlecompile
nnoremap <leader>r :SingleCompileRun<cr>
let g:SingleCompile_showquickfixiferror = 1
func! ChoosePythonCompiler()
    echo 'Please choose python compiler:\n'
    echo '1. Python2+\n'
    echo '2. Python3+\n'
    let flag = getchar()
    if flag == 49
        call SingleCompile#ChooseCompiler('python', 'python')
        execute 'SingleCompileRun'
    elseif flag == 50
        call SingleCompile#ChooseCompiler('python', 'python3')
        execute 'SingleCompileRun'
    endif
endfunc
autocmd filetype python nnoremap <buffer> <leader>r :call ChoosePythonCompiler()<cr>


"""""""""
" Markdown 
"""""""""
autocmd BufNewFile,BufReadPost *.md set filetype=markdown


"""""""""""
" Golang
"""""""""""
au Filetype go nnoremap <leader>v :vsp <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>s :sp <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>t :tab split <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>r :GoRun %<CR>

