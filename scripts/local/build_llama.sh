#!/bin/bash
# CUDA build of llama-server from third_party/llama.cpp into build/llama.cpp.
#   CUDAARCH   – GPU architecture (e.g. 89 for RTX 4060, 86 for 30xx, 75 for 20xx). Default 86.
#   CUDA_HOME  – path to your CUDA toolkit (defaults to /usr/local/cuda).
#   JOBS       – parallelism (defaults to 16).
set -euo pipefail
cd "$(dirname "$0")/../.."
git submodule update --init third_party/llama.cpp

CUDA_HOME="${CUDA_HOME:-/usr/local/cuda}"
CUDAARCH="${CUDAARCH:-86}"
NVCC="${CUDA_HOME}/bin/nvcc"
[[ ! -f "$NVCC" ]] && NVCC="$(command -v nvcc)"

cmake -S third_party/llama.cpp -B build/llama.cpp -DGGML_CUDA=ON \
    -DCMAKE_CUDA_COMPILER="$NVCC" -DCMAKE_CUDA_ARCHITECTURES="$CUDAARCH" -DCMAKE_BUILD_TYPE=Release
cmake --build build/llama.cpp --target llama-server -j "${JOBS:-16}"
ls -l build/llama.cpp/bin/llama-server
