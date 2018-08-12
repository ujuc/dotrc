if type go > /dev/null; then
    # Go Path
    export GOROOT=`go env GOROOT`
    export GOPATH=$HOME/repos/go
    export PATH=$PATH:/usr/local/opt/go/libexec/bin
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
fi

# NVM
if type nvm > /dev/null; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
fi

# Linux brew
if [[ $(uname -s) == "Linux" ]]; then
    export PATH="$HOME/.linuxbrew/bin:$PATH"
    export MANPATH="$MONE/.linuxbrew/share/man:$MANPATH"
    export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
fi

if [ -d $HOME/.pyenv ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)" 
fi

if [ -d $HOME/.rbenv ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)" 
fi

if [ -f $HOME/.item2_shell_integration.zsh ]; then
    source $HOME/.item2_shell_integration.zsh
fi

if [ -f $HOME/.config/exercism/exercism_completion.zsh ]; then
    . $HOME/.config/exercism/exercism_completion.zsh
fi

# pipenv
export PIPENV_VENV_IN_PROJECT=true
eval "$(pipenv --completion)"
