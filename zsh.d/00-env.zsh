# Environment setup
# Loaded first to set up paths and basic environment

# Zsh function file dir
ZFUNCDIR=${ZDOTDIR}/.zfunc
fpath=(${ZFUNCDIR} $fpath)

# User local binaries (claude, custom scripts, etc.)
if [[ -d "${HOME}/.local/bin" ]]; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi

# amp
if [[ -d "${HOME}/.amp/bin" ]]; then
    export PATH="${HOME}/.amp/bin:${PATH}"
fi
