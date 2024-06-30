#!/usr/bin/env bash

executable_exists( ) {
    command -v "$1" | wc -l
}

relative_to( ) {
    realpath -Lm --relative-to="$1" "$2"
}

reduce_path( ) {
    realpath -Lm --relative-to="$1" "$2"
}

repository_root( ) {
    realpath -Lm "$( dirname "$( git rev-parse --git-dir 2> /dev/null )" )"
}

file_inode( ) {
    stat "$1" | grep -Po "Inode:\s\K(\d+)"
}

file_device( ) {
    stat "$1" | grep -Po "Device:\s\K([0-9,]+)"
}

is_same_file( ) {
    if [[ "$( file_inode "$1" )" = "$( file_inode "$2" )" ]] && [[ "$( file_device "$1" )" = "$( file_device "$2" )" ]]; then
        echo -ne "1"
    else
        echo -ne "0"
    fi
}

service_exists( ) {
    target_service=$1

    [ "$( systemctl list-units --user 2>&1 | grep "${target_service}" | wc -l )" -ge 1 ] && echo -ne "1" || echo -ne "0"
}

# explicit word-splitting
# shellcheck disable=2046
export -f $( grep -Eo "^[a-z_]+\(\s*\)\s*{$" "${BASH_SOURCE[0]}" | grep -Eo "^[a-z_]+" | tr "\n" " " )
