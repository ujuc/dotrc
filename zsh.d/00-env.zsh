# Environment setup
# Loaded first to set up paths and basic environment

# Zsh function file dir
ZFUNCDIR=${ZDOTDIR}/.zfunc
fpath=(${ZFUNCDIR} $fpath)

# amp
if [[ -d "${HOME}/.amp/bin" ]]; then
    export PATH="${HOME}/.amp/bin:${PATH}"
fi
