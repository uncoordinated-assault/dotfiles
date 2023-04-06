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

# explicit word-splitting
# shellcheck disable=2046
export -f $( grep -Eo "^[a-z_]+\(\s*\)\s*{$" "${BASH_SOURCE[0]}" | grep -Eo "^[a-z_]+" | tr "\n" " " )
