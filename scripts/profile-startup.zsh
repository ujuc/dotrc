#!/usr/bin/env zsh
# Profile Zsh startup time using zprof
# Shows which functions and commands take the most time to load

DOTRCDIR="${DOTRCDIR:-${HOME}/.config/dotrc}"

echo "⏱️  Profiling Zsh startup time..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Run zsh with zprof enabled
zsh -c "
zmodload zsh/zprof
DOTRCDIR=${DOTRCDIR}
source ${DOTRCDIR}/zshrc
zprof
"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Tips for optimization:"
echo "  • Functions >50ms: Consider lazy loading"
echo "  • Functions >100ms: Definitely lazy load"
