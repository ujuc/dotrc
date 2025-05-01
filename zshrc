# history
setopt HIST_IGNORE_ALL_DUPS

# zimfw
ZIM_HOME=${XDG_CONFIG_HOME:-$HOME/.config}/zim
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
eval "$(starship init zsh)"

# asdf
if (($+commands[asdf])); then
    export ASDF_DATA_DIR=$HOME/.asdf
    export PATH="${ASDF_DATA_DIR}/shims:${PATH}"
fi

# deno
if [ -d "$HOME/.deno" ]; then
    export DENO_INSTALL_ROOT="$HOME/.deno"
    export PATH="${DENO_INSTALL_ROOT}/bin:$PATH"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# work
[ -f ~/.zshrc.work ] && source ~/.zshrc.work

function update_system() {
    brew update
    brew upgrade
    zimfw update && zimfw upgrade
    gh ext upgrade --all
    brew cleanup

    if (($+commands[asdf])); then
        asdf plugin update --all
    fi
}

# Aliases
alias update=update_system
alias bws="brew search"
alias bwi="brew install"

alias ls="lsd"
alias ll="lsd -l"
alias lt="lsd --tree"
alias cat="bat"
alias vi="vim"
