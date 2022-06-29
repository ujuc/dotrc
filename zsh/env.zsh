# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

REPOS=$HOME/repos

export GPG_TTY=$(tty)

# brew
export PATH="/usr/local/sbin:$PATH"

# starship
export DOTRC_STARSHIP="${DOTRC}/starship"
export STARSHIP_CONFIG="${DOTRC_STARSHIP}/config.toml"

# asdf
if (( $+commands[asdf] )); then
  . $(brew --prefix asdf)/libexec/asdf.sh
fi
