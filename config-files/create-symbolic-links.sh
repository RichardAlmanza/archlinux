#! /usr/bin/sh

WORKING_FILE=$(readlink -e $0)
WORKING_DIR=$(dirname $WORKING_FILE)

# Functions
rm_broken_links () {
    BROKEN_LINKS=$(find $1 -xtype l)
    
    if [[ -n "$BROKEN_LINKS" ]]; then
        echo "Broken links found in $1"

        for FILE in $BROKEN_LINKS
        do
            rm -v $FILE
        done
    else
        echo "No broken links found in $1"
    fi
}

bkup_old () {
    DATE_BK=$(date --iso-8601=seconds)

    for FILE in $@
    do
        if [[ "inode/symlink" == $(file --brief --mime-type $FILE) ]]; then
            rm $FILE
        else
            mv -v $FILE "${FILE}_${DATE_BK}"
        fi
    done
}

create_links () {
    DESTINATION_DIR=$1

    for FILE in ${@:2}
    do
        ORIGEN=$FILE
        DESTINATION=$DESTINATION_DIR/$(basename $FILE)
        bkup_old $DESTINATION
        ln -sv $ORIGEN $DESTINATION
    done
}

clone_repos () {
    DIRECTORY=$1
    REPOSITORIES=(${@:2})

    pushd $DIRECTORY

    for ITER in $(seq 1 2 ${#REPOSITORIES[@]})
    do
        NAME=${REPOSITORIES[@]:$(($ITER - 1)):1}
        REPOSITORY=${REPOSITORIES[@]:$ITER:1}

        git clone --depth=1 $REPOSITORY $DIRECTORY/$NAME
    done

    popd
}

link_config_dirs () {
    CONFIG_USER_DIR=$HOME/.config
    REPO_CONFIG_DIRS=$WORKING_DIR/others/*/

    echo "Creating links for some programs' config files"
    create_links $CONFIG_USER_DIR $REPO_CONFIG_DIRS
}

omz_config () {
    ZSH_CUSTOM=$ZSH/custom
    REPO_ZSH=$WORKING_DIR/oh-my-zsh
    REPO_ZSH_CUSTOM=$WORKING_DIR/oh-my-zsh/zsh_custom
    CLONE_PLUGINS=(
        "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    )

    echo "Cloning plugins for oh-my-zsh"
    clone_repos $REPO_ZSH_CUSTOM/plugins ${CLONE_PLUGINS[@]}

    echo "Creating links for oh-my-zsh config files"
    create_links $HOME $REPO_ZSH/.zshrc
    create_links $ZSH_CUSTOM $REPO_ZSH_CUSTOM/*.zsh
    create_links $ZSH_CUSTOM/themes $REPO_ZSH_CUSTOM/themes/*
    create_links $ZSH_CUSTOM/plugins $REPO_ZSH_CUSTOM/plugins/*
    
    rm_broken_links $ZSH_CUSTOM
}

omz_config
link_config_dirs
