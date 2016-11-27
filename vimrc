set runtimepath+=~/.vim_runtime

source ~/.vim_runtime/vimrcs/basic.vim
source ~/.vim_runtime/vimrcs/filetypes.vim
source ~/.vim_runtime/vimrcs/plugins_config.vim
source ~/.vim_runtime/vimrcs/extended.vim

"source ~/.vim/vimrcs/basic.vim
"source ~/.vim/vimrcs/plugins.vim
"source ~/.vim/vimrcs/plugins_config.vim

try
source ~/.vim_runtime/my_configs.vim
catch
endtry
