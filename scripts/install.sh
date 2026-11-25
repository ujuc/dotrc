#!/usr/bin/env bash
# install.sh — Thin launcher for the Rust installer in scripts/installer/.
# Installs a minimal Rust toolchain with rustup when cargo is missing, then builds
# and runs the installer; the first run compiles it. Usage: install.sh --help

set -euo pipefail

DOTRCDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
export DOTRCDIR

if ! command -v cargo >/dev/null 2>&1; then
    if [ ! -x "$HOME/.cargo/bin/cargo" ]; then
        echo "[rust] Install Rust toolchain with rustup"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
            sh -s -- -y --no-modify-path --profile minimal
    fi
    PATH="$HOME/.cargo/bin:$PATH"
fi

exec cargo run \
    --manifest-path "$DOTRCDIR/scripts/installer/Cargo.toml" \
    --release \
    --quiet \
    -- "$@"
