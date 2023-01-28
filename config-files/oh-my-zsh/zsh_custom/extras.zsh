# [ALIASES]
# lsd
alias l='lsd -ahl'
alias la='lsd -Ahl'
alias ll='lsd -hl'
alias lz='lsd -ahl --total-size'
alias lt='lsd -ahl --tree'
alias lta='lsd -Ahl --tree'
alias llt='lsd -hl --tree'

# [FUNCTIONS]

# needs Exercism and a configured --workspace; Git; VSCode
# $1 Track eg. Go; $2 Exercise eg. need-for-speed
function exercism_actions() {
    action=$1
    shift

    if [ $action = "start" ]; then
        sh "$ZSH_CUSTOM/scripts/exercism_actions.sh" --start $@
        return $?
    elif [ $action = "finish" ]; then
        sh "$ZSH_CUSTOM/scripts/exercism_actions.sh" --finish $@
        return $?
    fi

}
# [Extras]
