eval "$(starship init zsh)"

# zplug
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting"

zplug load

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Alias
if [[ $(uname -s) == "Darwin" ]]; then
    # OS X
    alias install="brew install"
    alias uninstall="brew uninstall --force"
    alias search="brew search"
    alias info="brew info"
    alias list="brew list"
    alias cask="brew cask"
    alias update="brew update; brew upgrade; brew cask upgrade; zplug update; asdf plugin update --all"
    alias cleanup="brew cleanup"
fi

alias ls='ls -G'
alias grep='grep --color=auto'
alias vi='nvim'

## dir
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

### Env below

# brew
export PATH="/usr/local/sbin:$PATH"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# poetry
source ~/.poetry/env
fpath+=~/.zfunc

# asdf settup
# TODO: 명령이 없는 경우 작동하지 않도록 설정
source $(brew --prefix asdf)/asdf.sh
if [[ -e $(brew --prefix asdf) ]]; then;
    export PATH="`asdf where python`/bin:$PATH"
    export PATH="`asdf where nodejs`/bin:$PATH"
fi

# iterm2 shell intergration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# TODO: 회사에서 만 사용하는 위치. 어서 빨리 2.0으로 올리고 수정하도록 한다.
export PATH="/usr/local/opt/awscli@1/bin:$PATH"
