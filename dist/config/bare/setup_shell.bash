#!/usr/bin/env bash

[ -f "$HOME/util/standard_lib.bash" ] && source "$HOME/util/standard_lib.bash"

declare -A DEFAULT_VARIABLES=(
    # single quotes to avoid expansion
    [PS1]='\[\e[0m\][\[\e[0m\]\u\[\e[0m\]]\[\e[0m\][\[\e[0m\]\W\[\e[0m\]]\n\[\e[0m\]> \[\e[0m\]'
)

for var_name in "${!DEFAULT_VARIABLES[@]}"; do
    var_value="${DEFAULT_VARIABLES["$var_name"]}"

    declare "${var_name}=${var_value}"
done


declare -A PROGRAM_SETUP=(
    [zoxide]="zoxide init bash"
    [starship]="starship init bash"
)

for program_name in "${!PROGRAM_SETUP[@]}"; do
    program_eval="${PROGRAM_SETUP["$program_name"]}"

    if [[ "$( executable_exists "$program_name" )" = 1 ]]; then
        eval "$( $program_eval )"
    fi
done

declare -A PROGRAM_ALIASES=(
    [cd]="z"
    [ls]="lsd -1 -l --icon never --date relative"
    [cat]="bat"
    [edit]="$EDITOR"
)

for alias_name in "${!PROGRAM_ALIASES[@]}"; do
    alias_value="${PROGRAM_ALIASES["$alias_name"]}"

    if [[ "$( executable_exists "$( echo -ne "$alias_value" | awk '{ print $1 }' )" )" = 1 ]]; then
        # expansion is required
        # shellcheck disable=2139
        alias "$alias_name"="$alias_value"
    fi
done

# require argument split
# shellcheck disable=2046
unset -v DEFAULT_VARIABLES $( compgen -v | grep -Eo "^PROGRAM_[A-Z]+$" | tr "\n" " " )
