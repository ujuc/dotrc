# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

REPOS=$HOME/repos

# brew
export PATH="/usr/local/sbin:$PATH"

# starship
export DOTRC_STARSHIP="${DOTRC}/starship"
export STARSHIP_CONFIG="${DOTRC_STARSHIP}/config.toml"

# asdf
if (( $+commands[asdf] )); then
  . $(brew --prefix asdf)/libexec/asdf.sh
fi

# saml2aws
if (( $+commands[saml2aws] )); then
  eval "$(saml2aws --completion-script-zsh)"
fi

# kubectl
if (( $+commands[kubectl] )); then
  export PATH="${PATH}:${HOME}/.krew/bin"
  # Todo: stg 값은 회사에서만 사용하는 것이기에 해당 부분 수정이 필요하다.
  export KUBECONFIG="${HOME}/.kube/config":"${REPOS}/kurly-kubernetes/kubeconfig-stg"
fi
