#!/usr/bin/env zsh
# Profile Zsh startup time
# Shows which modules take the most time to load

DOTRCDIR="${DOTRCDIR:-${HOME}/.config/dotrc}"

echo "⏱️  Profiling Zsh startup time..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create temporary instrumented zshrc
tmpfile=$(mktemp)
cat > ${tmpfile} << 'PROFILE_SCRIPT'
# Profiling instrumentation
typeset -F SECONDS=0

echo "Module                          Time (ms)"
echo "────────────────────────────────────────"

for config_file in ${DOTRCDIR}/zsh.d/*.zsh(N); do
    local start=$SECONDS
    source "${config_file}"
    local end=$SECONDS
    local elapsed=$(( (end - start) * 1000 ))
    printf "%-30s %8.2f ms\n" "${config_file:t}" ${elapsed}
done

echo "────────────────────────────────────────"
printf "%-30s %8.2f ms\n" "TOTAL" $(( SECONDS * 1000 ))
PROFILE_SCRIPT

# Run profiling
zsh -c "DOTRCDIR=${DOTRCDIR}; source ${tmpfile}"

# Cleanup
rm -f ${tmpfile}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Tips for optimization:"
echo "  • Modules >50ms: Consider lazy loading"
echo "  • Modules >100ms: Definitely lazy load"
echo "  • Run 'compile-zsh.sh' to speed up parsing"
