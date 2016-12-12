autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype html setlocal ts=4 sts=4 sw=4
autocmd FIletype javascript setlocal ts=4 sts=4 sw=4

au Filetype gitcommit set tw=72

au Filetype go nnoremap <leader>gdv :vsp <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>gds :sp <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>gdt :tab split <CR>:exe "GoDef"<CR>
au Filetype go nnoremap <leader>gr :GoRun %<CR>

