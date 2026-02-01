# Aliases and functions

# System update function
function update_system() {
    brew update
    brew upgrade
    zimfw update && zimfw upgrade
    brew cleanup
    mise self-update && mise up
    # gh ext upgrade --all
}

# Compile Zsh configs for faster loading
function compile_zsh() {
    ${DOTRCDIR}/scripts/compile-zsh.sh
}

# Benchmark Zsh startup time
function benchmark_zsh() {
    ${DOTRCDIR}/scripts/benchmark.sh "$@"
}

# Profile Zsh startup (show timing per module)
function profile_zsh() {
    ${DOTRCDIR}/scripts/profile-startup.zsh
}

# Update alias
alias update=update_system

# Zsh optimization aliases
alias zcompile=compile_zsh
alias zbench=benchmark_zsh
alias zprofile=profile_zsh

# Homebrew aliases
alias bws="brew search"
alias bwi="brew install"

# Modern CLI tool aliases
alias ls="eza --icons=auto --group-directories-first --git"
alias ll="eza -l --git --icons=auto"
alias lt="eza -l --tree --icons=auto"
alias cat="bat"
alias vi="vim"
