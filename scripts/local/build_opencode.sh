#!/bin/bash
# opencode (terminal UI only; the web UI build needs Node >= 20.12) from third_party/opencode into build/opencode.
# Installs bun 1.4.4 to ~/.bun if missing.
set -euo pipefail
cd "$(dirname "$0")/../.."
export PATH="$HOME/.bun/bin:$PATH"  # opencode's install hooks call plain `bun`
if ! bun --version 2>/dev/null | grep -q '^1\.4\.4$'; then
    curl -fsSL https://bun.sh/install | bash -s "bun-v1.4.4"
fi
git submodule update --init third_party/opencode
(cd third_party/opencode && bun install)
bun run --cwd third_party/opencode/packages/cli script/build.ts --single --skip-web-ui --outdir="$PWD/build/opencode"
ls -l build/opencode/*/bin/opencode
