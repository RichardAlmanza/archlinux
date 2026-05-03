#! /bin/sh

set -e

get_containers_by_name() {
    CONTAINER_RUNNER="$1"
    CONTAINER_NAME="$2"

    "$CONTAINER_RUNNER" ps --quiet --filter name="$CONTAINER_NAME"
}

flipflop_container() {
    CONTAINER_RUNNER="$1"
    CONTAINER_NAME="$2"
    CONTAINER_PROPERTIES="$3"
    EXTRA_ACTION="${@:4}"

    # Search container runner path
    if [ "$CONTAINER_RUNNER" = "docker" ]; then
        CONTAINER_RUNNER="$(command -v docker)"
    elif [ "$CONTAINER_RUNNER" = "podman" ]; then
        CONTAINER_RUNNER="$(command -v podman)"
    elif [ "$CONTAINER_RUNNER" = "any" ]; then
        { CONTAINER_RUNNER="$(command -v podman)"; } || \
        { CONTAINER_RUNNER="$(command -v docker)"; }
    else
        echo "Invalid option for container runner: ${CONTAINER_RUNNER}"
        exit 1
    fi

    # No container runner found
    if [ "$CONTAINER_RUNNER" = "" ]; then
        echo "No docker or podman found. Aborting"
        exit 1
    fi

    # Is container running?
    CONTAINER_ID="$(get_containers_by_name $CONTAINER_RUNNER $CONTAINER_NAME)"
    CONTAINER_ID="$(echo "$CONTAINER_ID" | tr --squeeze-repeats "[:blank:]")"

    # Stop running container
    if [ "$CONTAINER_ID" != "" ]; then
        echo "Stopping container ${CONTAINER_NAME}"
        "$CONTAINER_RUNNER" container stop "$CONTAINER_NAME"

    # Run container
    else
        echo "Using $(basename "$CONTAINER_RUNNER")"
        echo "Starting temporal container $CONTAINER_NAME"
        # shellcheck disable=SC2086
        "$CONTAINER_RUNNER" run \
            --rm -d \
            --name "$CONTAINER_NAME" \
            $CONTAINER_PROPERTIES && \
        $EXTRA_ACTION
    fi

}

chat_ollama() {
    OLLAMA_CONTAINER_NAME="ollama-container"
    WEB_UI_CONTAINER_NAME="open-webui"
    OLLAMA_PORT=11434
    WEB_UI_PORT="${1:-3535}"

    flipflop_container any \
        "$OLLAMA_CONTAINER_NAME" \
        "-v ollama:/root/.ollama \
            -p ${OLLAMA_PORT}:11434 \
            --gpus=all \
            --replace \
            docker.io/ollama/ollama" \
        && \
    flipflop_container any \
        "$WEB_UI_CONTAINER_NAME" \
        "-p ${WEB_UI_PORT}:8080 \
            -e OLLAMA_BASE_URL=http://localhost:${OLLAMA_PORT} \
            -v open-webui:/app/backend/data \
            --network=pasta:-T,11434 \
            --replace \
            ghcr.io/open-webui/open-webui:main" \
        "echo Open WebUI running at http://127.0.0.1:${WEB_UI_PORT}"
}

chat_ollama "$@"
