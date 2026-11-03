#!/bin/bash
# llama-server on :8080 for opencode. Extra args go to llama-server (later ones win).
# One slot (-np 1) so parallel requests queue instead of sharing the context.
# -fitt 1536 leaves ~1.5 GB VRAM free for the desktop; raise for more headroom, lower to fit more of the model on the GPU.
#   MODEL=... to pick a different quant (default: UD-Q4_K_XL).
#   [--vision] to load the vision projector (mmproj).
set -euo pipefail
cd "$(dirname "$0")/../.."
MODEL=${MODEL:-data/models/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf}
ARGS=()
[[ "${1:-}" == --vision ]] && { ARGS+=(--mmproj data/models/Qwen3.6-35B-A3B-mmproj-F16.gguf); shift; }
exec build/llama.cpp/bin/llama-server -m "$MODEL" --jinja -c 65536 -a qwen3.6-35b-a3b \
    -np 1 -fitt 1536 --host 127.0.0.1 --port 8080 "${ARGS[@]}" "$@"
