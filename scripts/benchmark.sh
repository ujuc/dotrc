#!/usr/bin/env bash
# Benchmark Zsh startup time.
# Prefers hyperfine for accurate statistics; falls back to a date-based loop.

set -e

RUNS=${1:-10}
DOTRCDIR="${DOTRCDIR:-${HOME}/.config/dotrc}"

# ── Preferred path: hyperfine (accurate, warmup-aware) ──────────
if command -v hyperfine >/dev/null 2>&1; then
    echo "🏃 Benchmarking Zsh startup with hyperfine (${RUNS} runs)..."
    echo ""
    # -N runs the command directly (no intermediate shell), so we time only zsh.
    hyperfine --warmup 5 --runs "${RUNS}" -N 'zsh -i -c exit'
    echo ""
    echo "💡 To profile which modules are slow:"
    echo "   ${DOTRCDIR}/scripts/profile-startup.zsh"
    exit 0
fi

# ── Fallback: date-based loop (coarser; includes date(1) overhead) ──
echo "🏃 Benchmarking Zsh startup time (${RUNS} runs)..."
echo "   (tip: 'brew install hyperfine' for more accurate stats)"
echo ""

# Array to store times
times=()
total=0

# Run benchmark
for i in $(seq 1 ${RUNS}); do
    # Measure time in milliseconds
    start=$(gdate +%s%3N 2>/dev/null || date +%s%3N)
    zsh -i -c exit > /dev/null 2>&1
    end=$(gdate +%s%3N 2>/dev/null || date +%s%3N)

    elapsed=$((end - start))
    times+=($elapsed)
    total=$((total + elapsed))

    printf "  Run %2d: %4d ms\n" $i $elapsed
done

# Calculate statistics
average=$((total / RUNS))
min=${times[0]}
max=${times[0]}

for time in "${times[@]}"; do
    if [[ $time -lt $min ]]; then
        min=$time
    fi
    if [[ $time -gt $max ]]; then
        max=$time
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Results (${RUNS} runs):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  Average: %4d ms\n" $average
printf "  Min:     %4d ms\n" $min
printf "  Max:     %4d ms\n" $max
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Performance rating
if [[ $average -lt 100 ]]; then
    echo "🚀 Excellent! Very fast startup."
elif [[ $average -lt 200 ]]; then
    echo "✅ Good! Acceptable startup time."
elif [[ $average -lt 500 ]]; then
    echo "⚠️  OK. Could be optimized further."
else
    echo "🐌 Slow. Consider more aggressive optimizations."
fi

echo ""
echo "💡 To profile which modules are slow:"
echo "   ${DOTRCDIR}/scripts/profile-startup.zsh"
