#!/usr/bin/env bash

[ -f "$HOME/util/standard_lib.bash" ] && source "$HOME/util/standard_lib.bash"

declare -A DEFAULT_VARIABLES=(
    # for pinentry to work inside tmux
    [export:GPG_TTY]="$( tty )"
    # single quotes to avoid expansion
    [PS1]='\[\e[0m\][\[\e[0m\]\u\[\e[0m\]]\[\e[0m\][\[\e[0m\]\W\[\e[0m\]]\n\[\e[0m\]> \[\e[0m\]'
)

for var_name in "${!DEFAULT_VARIABLES[@]}"; do
    var_value="${DEFAULT_VARIABLES["$var_name"]}"

    if (
        shopt -s nocasematch;
        [[ "$var_name" =~ ^export: ]]
    ); then
        var_name="$( echo "$var_name" | grep -Po "(?i)^export:\K([a-z_][a-z_0-9]*)$" )"

        declare "${var_name}=${var_value}"

        export "${var_name?}"

        continue
    fi

    declare "${var_name}=${var_value}"
done


declare -A PROGRAM_SETUP=(
    [eval:zoxide]="zoxide init bash"
    [eval:starship]="starship init bash"
    # refresh gnupg's target tty
    [gpg-agent]="gpg-connect-agent updatestartuptty /bye 2>&1 > /dev/null"
)

for program_name in "${!PROGRAM_SETUP[@]}"; do
    program_cmd="${PROGRAM_SETUP["$program_name"]}"

    should_eval=0

    if (
        shopt -s nocasematch;
        [[ "$program_name" =~ ^eval: ]]    
    ); then
        should_eval=1
        
        program_name="$( echo "$program_name" | grep -Po "(?i)^eval:\K([a-z_][a-z_0-9]*)" )"
    fi

    if [[ "$( executable_exists "$program_name" )" = 1 ]]; then
        if [[ "$should_eval" = 1 ]]; then
            eval "$( $program_cmd )"    
        else
            eval "$program_cmd"
        fi
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
