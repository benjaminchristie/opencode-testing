# opencode + llama.cpp for local LLM work

Sets up OpenCode (terminal UI) with Qwen3.6-35B-A3B via llama-server on a local GPU.

## Prerequisites

- CUDA toolkit (for llama-server build)
- cmake and a C++ compiler
- `bash`, `curl`

## One-time setup

```bash
bash scripts/local/download_model.sh [--vision] [QUANT]
# QUANT defaults to UD-Q4_K_XL (22.4 GB file). If RAM is tight: UD-IQ4_XS (17.7 GB)
# Use --vision to also download the mmproj file.

bash scripts/local/build_llama.sh        # llama-server from third_party/llama.cpp
bash scripts/local/build_opencode.sh     # opencode CLI (installs bun 1.4.4 to ~/.bun if missing)
```

Both scripts initialize the `third_party/` submodules, pinned to llama.cpp b12079 and opencode v2.2.5.

## Running

```bash
# Terminal 1: serve the model
bash scripts/local/serve.sh [--vision]

# Terminal 2: start opencode
bash scripts/local/opencode.sh
```

`serve.sh` uses 65536 context on port 8080 with a single slot. 64k of context costs ~1.3 GB of KV cache (only 10 of 40 layers use full attention). `opencode.sh` checks that the server is up before launching.

### Choosing a quant

Pick the quant with `MODEL=...` on the `serve.sh` command line:

```bash
MODEL=data/models/Qwen3.6-35B-A3B-UD-IQ4_XS.gguf bash scripts/local/serve.sh
```

Any quant is served under the alias `qwen3.6-35b-a3b` (`-a` in `serve.sh`), which must match the model key in `opencode.json`.

### VRAM

`serve.sh` passes `-fitt 1536`, which leaves ~1.5 GB of VRAM free for the desktop. Raise it if other apps need more room, lower it to put more of the model on the GPU. The `-np 1` flag means parallel requests queue rather than sharing the context.

## Files

| Path | Purpose |
|---|---|
| `opencode.json` | Provider config (llama.cpp endpoint), model key, and limits |
| `scripts/local/serve.sh` | llama-server wrapper (65536 ctx, single slot, VRAM headroom) |
| `scripts/local/opencode.sh` | opencode CLI wrapper with server health check |
| `scripts/local/download_model.sh` | Qwen3.6-35B-A3B GGUF download with retry + sha256 verification |
| `scripts/local/build_llama.sh` | llama.cpp CUDA build (CUDAARCH env override for GPU architecture) |
| `scripts/local/build_opencode.sh` | opencode CLI build (bun 1.4.4, no web UI) |
