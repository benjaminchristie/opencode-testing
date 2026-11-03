#!/bin/bash
# opencode with the local llama.cpp model. Needs serve.sh running.
set -euo pipefail
cd "$(dirname "$0")/../.."
curl -sf -m 3 http://127.0.0.1:8080/v1/models >/dev/null || { echo "llama-server is not up: run scripts/local/serve.sh" >&2; exit 1; }
exec build/opencode/*/bin/opencode "$@"
