#! /bin/sh

set -e


usage()
{
  echo "Usage: exercism_actions [ --start | --finish ] track exercise"
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

finish() {
    run_test() {
        case $track in
            "go")
                go test -v .
            ;;
        esac
    }

    get_file_name() {
        case $track in
            "go") echo "$exercise.go" ;;
        esac
    }

    pushd $workspace_path/$exercise_path
        run_test
        git add $(get_file_name)
        git commit --message "${exercise_path} solution"
        exercism submit $(get_file_name)
    popd
}

run_start=false
run_finish=false
track=unset
exercise=unset

options=$(getopt --name exercism_actions --longoptions start,finish -- "" $@)

valid_options=$?

if [ "$valid_options" != "0" ]; then
    usage
fi

eval set -- "$options"

while true; do
    case $1 in
        --start) run_start=true; shift;;
        --finish) run_finish=true; shift;;
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
