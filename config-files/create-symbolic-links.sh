#! /usr/bin/sh

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
            rm -v $FILE
        else
            mv -v $FILE "${FILE}_${DATE_BK}"
        fi
    done
}

create_links () {
    
    for FILE in ${@:2}
    do
        ORIGEN=$FILE
        DESTINATION=$1/$(basename $FILE)
        bkup_old $DESTINATION
        ln -sv $ORIGEN $DESTINATION
    done
}

omz_config () {
    ZSH_CUSTOM=$ZSH/custom
    REPO_ZSH=$PWD/oh-my-zsh
    REPO_ZSH_CUSTOM=$PWD/oh-my-zsh/zsh_custom

    create_links $HOME $REPO_ZSH/.zshrc
    create_links $ZSH_CUSTOM $REPO_ZSH_CUSTOM/*.zsh
    create_links $ZSH_CUSTOM/themes $REPO_ZSH_CUSTOM/themes/*
    
    rm_broken_links $ZSH_CUSTOM
}

lsd_config () {
    CONFIG_USER_DIR=$HOME/.config
    REPO_CONFIG_DIR=$PWD/lsd

    create_links $CONFIG_USER_DIR $REPO_CONFIG_DIR
}

omz_config
lsd_config