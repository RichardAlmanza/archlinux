#! /bin/sh

set -e

# loads external functions
WORKING_FILE=$(readlink -e "$0")
WORKING_DIR=$(dirname "$WORKING_FILE")
. "$WORKING_DIR"/utils/container_management.sh

container_open_webui() {
    # First param is for the port to use OpenWeb UI
    WEB_UI_PORT="${1:-3535}"
    WEB_UI_CONTAINER_NAME="open-webui"
    OLLAMA_PORT=11434
    LLAMA_CPP_PORT=11435
    
    flipflop_container any \
        "$WEB_UI_CONTAINER_NAME" \
        "-p ${WEB_UI_PORT}:8080 \
            -e OLLAMA_BASE_URL=http://localhost:${OLLAMA_PORT} \
            -e OPENAI_API_BASE_URL=http://127.0.0.1:${LLAMA_CPP_PORT}/v1 \
            -e ENABLE_OPENAI_API=True \
            -e OPENAI_API_KEY=elpepe \
            -v open-webui:/app/backend/data \
            --network=pasta:-T,${OLLAMA_PORT}-${LLAMA_CPP_PORT} \
            --replace \
            ghcr.io/open-webui/open-webui:main" \
        "echo Open WebUI running at http://127.0.0.1:${WEB_UI_PORT}"
}

container_open_webui "$@"
