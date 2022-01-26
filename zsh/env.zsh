# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# brew
export PATH="/usr/local/sbin:$PATH"

# starship
export STARSHIP_CONFIG="$HOME/dotrc/starship/config.toml"

# asdf
. $(brew --prefix asdf)/libexec/asdf.sh

# saml2aws
if (( $+commands[saml2aws] )); then
  eval "$(saml2aws --completion-script-zsh)"
fi
