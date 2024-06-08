#!/bin/bash

shopt -s extglob

rename() {
	SRC="${MAPFILE[n]}"
	DST="${PREFIX[i]}-${MAPFILE[n]#+([0-9])-}"
	[[ "$SRC" != "$DST" ]] && mv "$SRC" "$DST"
}

cd "$1" || exit

mapfile -t < <(find -maxdepth 1 -type f -iname "*.mp3" -printf "%f\n")
N=${#MAPFILE[@]}

PREFIX=($(seq -w $N))
for ((n = 0; n < N - 1; n++)); do
	i=$((n + $RANDOM % (N - n)))
	rename
	PREFIX[i]=${PREFIX[n]}
done
i=$n
[[ i -gt 0 ]] && rename
