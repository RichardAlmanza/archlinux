#! /bin/sh

set -e

get_containers_by_name() {
    CONTAINER_RUNNER="$1"
    CONTAINER_NAME="$2"

    "$CONTAINER_RUNNER" ps --quiet --filter name="$CONTAINER_NAME"
}

chat_ollama() {
    CONTAINER_RUNNER=""
    OLLAMA_CONTAINER_NAME="ollama-container"
    WEB_UI_CONTAINER_NAME="open-webui"
    OLLAMA_PORT=11434
    WEB_UI_PORT="${1:-3535}"

    { CONTAINER_RUNNER="$(command -v podman)"; } || \
    { CONTAINER_RUNNER="$(command -v docker)"; } || \
    { echo "No docker or podman found. Aborting"; exit 1; }

    CONTAINERS_RUNNING="\
        $(get_containers_by_name $CONTAINER_RUNNER $OLLAMA_CONTAINER_NAME) \
        $(get_containers_by_name $CONTAINER_RUNNER $WEB_UI_CONTAINER_NAME) \
        "
    CONTAINERS_RUNNING="$(echo "$CONTAINERS_RUNNING" | tr --squeeze-repeats "[:blank:]")"


    if [ "$CONTAINERS_RUNNING" != " " ]; then
        echo "Shutting down containers"

        for CONTAINER_ID in ${CONTAINERS_RUNNING[@]}; do
            echo "Stopping container ${CONTAINER_ID}"
            "$CONTAINER_RUNNER" container stop "$CONTAINER_ID"
        done

        exit 0
    fi


    echo "Using $CONTAINER_RUNNER"
    echo "Starting container $OLLAMA_CONTAINER_NAME"
    "$CONTAINER_RUNNER" run --rm -d \
        -v ollama:/root/.ollama \
        -p "$OLLAMA_PORT":11434 \
        --gpus=all \
        --name "$OLLAMA_CONTAINER_NAME" \
        --replace \
        docker.io/ollama/ollama && \
    echo "Starting container $WEB_UI_CONTAINER_NAME" && \
    "$CONTAINER_RUNNER" run --rm -d \
        -p "$WEB_UI_PORT":8080 \
        -e OLLAMA_BASE_URL=http://localhost:"$OLLAMA_PORT" \
        -v open-webui:/app/backend/data \
        --name "$WEB_UI_CONTAINER_NAME" \
        --network=pasta:-T,11434 \
        --replace \
        ghcr.io/open-webui/open-webui:main && \
    echo "Open WebUI running at http://localhost:${WEB_UI_PORT}"
}

chat_ollama "$1"
