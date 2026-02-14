# Modular Zsh configuration
# Main loader - sources all configs from zsh.d/

# Auto-compile this file if modified
if [[ ! -f ${DOTRCDIR}/zshrc.zwc ]] || [[ ${DOTRCDIR}/zshrc -nt ${DOTRCDIR}/zshrc.zwc ]]; then
    zcompile ${DOTRCDIR}/zshrc
fi

# Load all configuration modules in order
# Naming convention: XX-name.zsh where XX is load order (00-99)
for config_file in ${DOTRCDIR}/zsh.d/*.zsh(N); do
    # Auto-compile module if modified or not compiled yet
    if [[ ! -f ${config_file}.zwc ]] || [[ ${config_file} -nt ${config_file}.zwc ]]; then
        zcompile ${config_file}
    fi
    source "${config_file}"
done
unset config_file

# JetBrains Toolbox CLI scripts
if [[ -d "/Users/ujuc/Library/Application Support/JetBrains/Toolbox/scripts" ]]; then
    export PATH="${PATH}:/Users/ujuc/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# Obsidian CLI
if [[ -d "/Applications/Obsidian.app" ]]; then
    export PATH="${PATH}:/Applications/Obsidian.app/Contents/MacOS"
fi

# entire completion
if (( $+commands[entire] )); then
    source <(entire completion zsh)
fi
