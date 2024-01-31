#! /bin/sh
# shellcheck disable=SC3044

set -e

# loads external functions
WORKING_FILE=$(readlink -e "$0")
WORKING_DIR=$(dirname "$WORKING_FILE")


#. $WORKING_DIR/utils/*
# shellcheck source=utils/pushd_popd.sh
. "$WORKING_DIR"/utils/pushd_popd.sh

usage()
{
  echo "Usage: exercism_actions [ --start | --finish | --test ] track exercise
                        [ --start | --finish | --test ] --solution-file file-name track exercise"
  exit 2
}

start() {
    exercism download --exercise="$exercise" --track="$track"

    pushd "$workspace_path"
        git add "$exercise_path"
        git commit --message "download ${exercise_path}"
    popd

    code "$workspace_path"/"$exercise_path"
}

get_file_name() {
    case $track in
        "go") echo "$(echo "$exercise" | tr '-' '_').go" ;;
        "elixir") echo "lib/$(echo "$exercise" | tr '-' '_').ex" ;;
        "rust") echo "src/lib.rs" ;;
    esac
}

run_test() {
    pushd "$workspace_path"/"$exercise_path"

    case $track in
        "go")
            go test -v .
        ;;
        "elixir")
            docker run -it -v "$PWD":/app --workdir=/app --rm elixir mix test
        ;;
        "rust")
            docker run -it -v "$PWD":/app --workdir=/app --rm rust cargo test -- --include-ignored --show-output
        ;;
    esac

    popd
}

finish() {
    file_name=${file_name:-$(get_file_name)}

    pushd "$workspace_path"/"$exercise_path"
        run_test
        git add "$file_name"
        git commit --message "${exercise_path} solution"
        exercism submit "$file_name"
    popd
}

run_start=false
run_finish=false
run_test=false
track=""
exercise=""

while [ "$#" -gt 0 ]
do
    case $1 in
        -s | --start) run_start=true; shift;;
        -f | --finish) run_finish=true; shift;;
        -t | --test) run_test=true; shift;;
        -sf | --solution-file) file_name=$2; shift 2; break;;
        -- | -)
            shift;

            if test "$1" != "-sf" && test "$1" != "--solution-file" ; then
                break
            fi
            ;;
        -*) usage;;
        *) usage;;
    esac
done

if [ "$#" -lt 2 ]; then
    echo too few arguments
    usage
fi

track=$1
exercise=$2
exercise_path=$track/$exercise
workspace_path=$(exercism workspace)

if [ $run_start = "true" ]; then
    start
fi

if [ $run_finish = "true" ]; then
    finish
fi

if [ $run_test = "true" ]; then
    run_test
fi
