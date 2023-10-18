#! /bin/bash
dirs=("i3" "polybar" "helix" "wezterm" "picom")
mkdir -p config
for dir in "${dirs[@]}"
do
  cp -Rf ~/.config/$dir ./config/
done

mkdir -p root

cp -f ~/.zshrc ./root/zshrc
cp -f ~/.zshenv ./root/zshenv