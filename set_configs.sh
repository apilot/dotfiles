#! /bin/bash

cp -Rf ~/config/* ./.config/
mkdir -p .oh-my-ssh
cp -R ./root/oh-my-zsh/* ~/.oh-my-zsh/
cp -f ./root/zshrc ~/.zshrc
cp -f ./root/zshenv ~/.zshenv