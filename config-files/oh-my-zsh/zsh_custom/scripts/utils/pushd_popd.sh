#! /bin/sh

set -e

LAST_DIRS=$PWD

pushd() {
    new_dir=$(readlink -e "$1")
    LAST_DIRS="$new_dir $LAST_DIRS"

    cd "$new_dir"
}

popd() {
    # shellcheck disable=SC2086
    set -- $LAST_DIRS
    shift

    if [ -z "$1" ]; then
        return
    fi

    LAST_DIRS="$*"

    cd "$1"
}

dirs() {
    echo "$LAST_DIRS"
}