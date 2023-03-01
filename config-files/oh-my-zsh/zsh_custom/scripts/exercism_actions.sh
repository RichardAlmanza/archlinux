#! /bin/sh

set -e


usage()
{
  echo "Usage: exercism_actions [ --start | --finish | --test ] track exercise
                        [ --start | --finish | --test ] --solution-file file-name track exercise"
  exit 2
}

start() {
    exercism download --exercise=$exercise --track=$track

    pushd $workspace_path
        git add $exercise_path
        git commit --message "download ${exercise_path}"
    popd

    code $workspace_path/$exercise_path
}

get_file_name() {
    case $track in
        "go") echo "$(echo $exercise | tr '-' '_').go" ;;
        "elixir") echo "lib/$(echo $exercise | tr '-' '_').ex" ;;
    esac
}

run_test() {
    case $track in
        "go")
            go test -v .
        ;;
        "elixir")
            docker run -it -v $PWD:/app --workdir=/app --rm elixir mix test
        ;;
    esac
}

finish() {
    file_name=${file_name:-$(get_file_name)}

    pushd $workspace_path/$exercise_path
        run_test
        git add $file_name
        git commit --message "${exercise_path} solution"
        exercism submit $file_name
    popd
}

run_start=false
run_finish=false
run_test=false
track=unset
exercise=unset

options=$(getopt --name exercism_actions --longoptions start,finish,test,solution-file: -- "" $@)

valid_options=$?

if [ "$valid_options" != "0" ]; then
    usage
fi

eval set -- "$options"

while true; do
    case $1 in
        --start) run_start=true; shift;;
        --finish) run_finish=true; shift;;
        --test) run_test=true; shift;;
        --solution-file) file_name=$2; shift 2;;
        --) shift; break;;
        *) echo "Unexpected option: $1 - this should not happen."; usage;;
    esac
done

track=$1
exercise=$2
exercise_path=$track/$exercise
workspace_path=$(exercism workspace)

if [ $run_start == "true" ]; then
    start
fi

if [ $run_finish == "true" ]; then
    finish
fi

if [ $run_test == "true" ]; then
    run_test
fi
