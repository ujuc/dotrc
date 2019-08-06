if type go > /dev/null; then
    # Go Path
    export GOROOT=`go env GOROOT`
    export PATH=$PATH:$GOROOT/bin
fi

# Linux brew
if [[ $(uname -s) == "Linux" ]]; then
    export PATH="$HOME/.linuxbrew/bin:$PATH"
    export MANPATH="$MONE/.linuxbrew/share/man:$MANPATH"
    export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
fi

# pyenv
if [ -d $HOME/.pyenv ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)" 
fi

# rbenv
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
if type pipenv > /dev/null; then
    export PIPENV_VENV_IN_PROJECT=true
    eval "$(pipenv --completion)"
fi

# zlib setup
if [[ $(uname -s) == "Darwin" ]]; then
    export CPPFLAGS="-I/usr/local/opt/zlib/include"
fi


# phpbrew
[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# poetry
if [ -d $HOME/.poetry ]; then
    source $HOME/.poetry/env
fi


if [ -d $HOME/.cargo ]; then
    source $HOME/.cargo/env
fi
