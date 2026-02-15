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

# JetBrains Toolbox CLI scripts
if [[ -d "/Users/ujuc/Library/Application Support/JetBrains/Toolbox/scripts" ]]; then
    export PATH="${PATH}:/Users/ujuc/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# Obsidian CLI
if [[ -d "/Applications/Obsidian.app" ]]; then
    export PATH="${PATH}:/Applications/Obsidian.app/Contents/MacOS"
fi
