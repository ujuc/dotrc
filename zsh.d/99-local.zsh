# Local and work-specific configurations
# Loaded last to allow overrides

# Work-specific config (gitignored)
if [[ -f ${HOME}/.zshrc.work ]]; then
    source ${HOME}/.zshrc.work
fi

# 1Password CLI plugins
if [[ -f ${XDG_CONFIG_HOME:-${HOME}/.config}/op/plugins.sh ]]; then
    source ${XDG_CONFIG_HOME:-${HOME}/.config}/op/plugins.sh
fi
