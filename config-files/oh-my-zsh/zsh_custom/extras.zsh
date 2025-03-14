# [ALIASES]
# lsd
alias l='lsd -ahl'
alias la='lsd -Ahl'
alias ll='lsd -hl'
alias lz='lsd -ahl --total-size'
alias lt='lsd -ahl --tree'
alias lta='lsd -Ahl --tree'
alias llt='lsd -hl --tree'

# go-task
alias task='go-task'

# [FUNCTIONS]

function find-aliases() {
    regx="($1"
    second_regx="([a-zA-Z]*$1[a-zA-Z]*"
    shift

    while [ "$#" -gt 0 ]; do
        regx="${regx}).*($1"
        second_regx="${second_regx}|[a-zA-Z]*$1[a-zA-Z]*"
        shift
    done

    regx="${regx})"
    second_regx="${second_regx})"

    alias | grep -i -E "$regx" | grep -i -E "$second_regx"
}

function fa() {
    find-aliases "$@"
}

function blackbox() {
    userid="1000"
    groupid="1000"
    credentials="/etc/samba/credentials/blackbox"
    smb_path="//192.168.1.36/Richard"
    mount_path="/home/anaeru/shared"

    if mount | grep -qs "$mount_path "; then
        sudo umount "$mount_path"
    else
        sudo mount -t cifs -o vers=3.0,uid=$userid,gid=$groupid,credentials=$credentials  "$smb_path" "$mount_path"
    fi
}

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
