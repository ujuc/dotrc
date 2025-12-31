# history
setopt HIST_IGNORE_ALL_DUPS

# Zsh function file dir
ZFUNCDIR=${ZDOTDIR}/.zfunc
fpath=(${ZFUNCDIR} $fpath)

# zimfw
ZIM_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}/zim
## 없으면 설치한다
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
## init
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR}/.zimrc} ]]; then
    source ${ZIM_HOME}/zimfw.zsh init
fi
source ${ZIM_HOME}/init.zsh

zstyle ':zim:zim:zim' use 'degit'

## zsh-autosuggestions
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

## zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

## zsh-history-substring-search
zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

# starship
_evalcache starship init zsh

# fzf
if [[ -f ${HOME}/.fzf.zsh ]]; then
    source ${HOME}/.fzf.zsh
else
    source <(fzf --zsh)
fi

# zoxide
if (( $+commands[zoxide] )); then
    _evalcache zoxide init zsh
fi

# mise (zoxide 다음에 위치해야 PROMPT_COMMAND 훅이 정상 동작)
if (( $+commands[mise] )); then
    _evalcache mise activate zsh
fi

# amp
if [[ -d "$HOME/.amp/bin" ]]; then
    export PATH="$HOME/.amp/bin:$PATH"
fi

# work
[ -f ${HOME}/.zshrc.work ] && source ${HOME}/.zshrc.work

function update_system() {
    brew update
    brew upgrade
    zimfw update && zimfw upgrade
    brew cleanup
    mise up
    # gh ext upgrade --all
}

# Aliases
alias update=update_system
alias bws="brew search"
alias bwi="brew install"

alias ls="eza --icons=auto --group-directories-first --git"
alias ll="eza -l --git --icons=auto"
alias lt="eza -l --tree --icons=auto"
alias cat="bat"
alias vi="vim"

source ${XDG_CONFIG_HOME:-${HOME}/.config}/op/plugins.sh
