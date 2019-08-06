" 기본 값 들 변경

nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')

" fzf

"
nnoremap <leader>u :UndotreeToggle<cr>
nnoremap <leader>n :NERDTree<cr>

" ale
nnoremap <leader>a<C-k> <Plug>(ale_previous_wrap)
nnoremap <leader>a<C-j> <Plug>(ale_next_wrap)
