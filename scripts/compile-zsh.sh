#!/usr/bin/env zsh
# Compile Zsh configuration files for faster loading
# Run this after modifying zshrc or zshenv

set -e

DOTRCDIR="${DOTRCDIR:-${HOME}/.config/dotrc}"
ZDOTDIR="${ZDOTDIR:-${HOME}/.config/zsh}"

echo "🔨 Compiling Zsh configuration files..."
echo ""

# Compile main zshrc
if [[ -f ${DOTRCDIR}/zshrc ]]; then
    echo "  Compiling zshrc..."
    zcompile ${DOTRCDIR}/zshrc
fi

# Compile zshenv
if [[ -f ${DOTRCDIR}/zshenv ]]; then
    echo "  Compiling zshenv..."
    zcompile ${DOTRCDIR}/zshenv
fi

# Compile zcompdump (completion cache)
if [[ -f ${ZDOTDIR}/.zcompdump ]]; then
    echo "  Compiling .zcompdump..."
    zcompile ${ZDOTDIR}/.zcompdump
fi

# Compile zimfw init
if [[ -f ${HOME}/.config/zim/init.zsh ]]; then
    echo "  Compiling zimfw init.zsh..."
    zcompile ${HOME}/.config/zim/init.zsh
fi

echo ""
echo "✅ Compilation complete!"
echo ""
echo "Compiled files (.zwc) are generated alongside originals."
echo "Zsh will automatically use compiled versions for faster loading."
echo ""
echo "💡 Tip: Run this script after updating zshrc or zshenv:"
echo "   ${DOTRCDIR}/scripts/compile-zsh.sh"
