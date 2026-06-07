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
echo "💡 Tips for optimization (startup):"
echo "  • Functions >50ms: Consider lazy loading"
echo "  • Functions >100ms: Definitely lazy load"
echo ""
echo "💡 Prompt-lag & input latency are separate dimensions — measure them too:"
echo "  • Per-module render cost:  starship timings"
echo "  • Slow-repo git cost:      cd <big-repo> && time git status"
echo "  • Accurate startup stats:  zbench   (uses hyperfine if installed)"
