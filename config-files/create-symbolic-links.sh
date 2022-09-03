#! /usr/bin/sh
ZSH_CUSTOM=$ZSH/custom

rm ~/.zshrc
ln -s $PWD/oh-my-zsh/.zshrc  ~/.zshrc

# remove broken links
for file in $(find $ZSH_CUSTOM -xtype l)
do
    rm $file
done

# create links for zsh_custom
for file in $PWD/oh-my-zsh/zsh_custom/*.zsh
do
    ln -s $file $ZSH_CUSTOM/.
done
# create links for themes
for file in $PWD/oh-my-zsh/zsh_custom/themes/*
do
    ln -s $file $ZSH_CUSTOM/themes/.
done

