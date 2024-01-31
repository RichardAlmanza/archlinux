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
    track=$1
    exercise=$2
    action=$3

    # Arch uses bash as sh  ||  linked /bin/sh => /bin/bash
    # This messes up other distros like Ubuntu
    sh "$ZSH_CUSTOM/scripts/exercism_actions.sh" --$action -- $track $exercise
    return $?
}
# [Extras]
