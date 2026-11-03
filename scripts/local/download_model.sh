#!/bin/bash
# Qwen3.6-35B-A3B GGUF -> data/models. Resumes, retries dropped connections, checks sha256 at the end.
#   bash scripts/local/download_model.sh [--vision] [QUANT]     QUANT defaults to UD-Q4_K_XL (fallback: UD-IQ4_XS)
set -euo pipefail
cd "$(dirname "$0")/../.."
VISION=0; [[ "${1:-}" == --vision ]] && { VISION=1; shift; }
QUANT=${1:-UD-Q4_K_XL}
REPO=unsloth/Qwen3.6-35B-A3B-GGUF
mkdir -p data/models

fetch() {  # fetch <file in repo> <local path>
    local sha size
    read -r sha size < <(curl -sf "https://huggingface.co/api/models/$REPO/tree/main" |
        python3 -c "import sys,json; f=next(f for f in json.load(sys.stdin) if f['path']=='$1'); print(f['lfs']['oid'], f['lfs']['size'])")
    for attempt in $(seq 1 30); do
        [[ -f "$2" && $(stat -c %s "$2") == "$size" ]] && break
        # --http1.1: HF's CDN drops long HTTP/2 streams; stalls under 50 kB/s for 60 s restart the connection
        curl -L -C - --http1.1 --speed-limit 50000 --speed-time 60 -o "$2" "https://huggingface.co/$REPO/resolve/main/$1" && break
        echo "attempt $attempt failed, resuming in 10 s" >&2; sleep 10
    done
    echo "checking sha256 of $2"
    echo "$sha  $2" | sha256sum -c -
}

fetch Qwen3.6-35B-A3B-$QUANT.gguf data/models/Qwen3.6-35B-A3B-$QUANT.gguf
if (( VISION )); then
    fetch mmproj-F16.gguf data/models/Qwen3.6-35B-A3B-mmproj-F16.gguf
fi
