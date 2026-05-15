#! /bin/sh

set -e

# loads external functions
WORKING_FILE=$(readlink -e "$0")
WORKING_DIR=$(dirname "$WORKING_FILE")
. "$WORKING_DIR"/utils/container_management.sh

container_llama_cpp() {
    # First param is to setup the model context-window
    CONTEXT_SIZE="${1:-32000}" 
    LLAMA_MODEL="${2:-Qwen3.5-9B-DeepSeek-V4-Flash-Q4_K_M.gguf}"
    LLAMA_CPP_PORT="${3:-11435}"

    LLAMA_CONTAINER_NAME="llama-cpp"

    # vulkan image is compatible in general, but using cuda seems to improve
    # performance about 10-13% relatively with vulkan on nvidia gpus
    # ghcr.io/ggml-org/llama.cpp:full-vulkan 
    flipflop_container any \
        "$LLAMA_CONTAINER_NAME" \
        "-p ${LLAMA_CPP_PORT}:8080 \
            -v ai-models:/models/ \
            --gpus all \
            --replace \
            ghcr.io/ggml-org/llama.cpp:full-cuda \
            --server \
            --model /models/${LLAMA_MODEL} \
            --host 0.0.0.0 \
            --port 8080 \
            --ctx-size ${CONTEXT_SIZE} \
            --temp 0.7 \
            --top-p 0.95 \
            --top-k 20 \
            --min-p 0.0 \
            --jinja \
            --fit on \
            --n-gpu-layers 99" \
        "echo Llama.cpp Web running at http://127.0.0.1:${LLAMA_CPP_PORT}"
}

container_llama_cpp "$@"
