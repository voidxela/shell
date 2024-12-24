#!/bin/bash
set -uo pipefail
printf "A># Installing symlinks...\n"
home="${X4_HOME:-"$HOME"}"
local_home="${X4_LOCAL:="$home/Local"}"
config="${X4_CONFIG:-"$local_home/config"}"
source="$(pwd)"
printf "I># Home: %s\n" "$home"
printf "I># Local: %s\n" "$local_home"
printf "I># Source: %s\n" "$source"
which yq 1> /dev/null
if [[ "$?" != "0" ]]; then
    printf "W>! Missing required tool yq. [https://github.com/mikefarah/yq]\n"
    printf "A># Installing yq with golang...\n"
    which go 1> /dev/null
    if [[ "$?" != "0" ]]; then
        printf "F># Missing tool go; unable to install yq. Install yq or golang and try again. Bye!\n"
        exit 1
    fi
    # https://github.com/mikefarah/yq?tab=readme-ov-file#go-install
    go install github.com/mikefarah/yq/v4@latest && which yq
    if [[ "$?" != "0" ]]; then
        printf "F># Install yq failed! See compiler output or ensure golang PATH is correct. Bye!\n"
        exit 1
    fi
    printf "S># Install yq ok!\n"
fi
set -e
eval "$(yq -o shell "$source/links.yml")"
n="$(($(yq -o csv .links links.yml | wc -l) - 1))"
printf "I># Found %d configured links [fs:%s]\n" "$n" "$source/links.yml"
for i in $(seq 0 $(($n - 1))); do
    from="$(eval "printf %s/%s \"$source\" \"\$links_${i}_from\"")"
    to="$(eval "printf %s/%s \"$home\" \"\$links_${i}_to\"")"
    printf "I># Creating link from [fs:%s] to [fs:%s]\n" "$from" "$to"
    mkdir -p "$(dirname "$to")"
    ln -svfT "$from" "$to"
done
printf "S># Install symlinks ok!\n"
