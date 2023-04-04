#!/usr/bin/env bash

[ -f "$HOME/util/standard_lib.bash" ] && source "$HOME/util/standard_lib.bash"

declare -A DEFAULT_ENVIRONMENT=(
    [ARCH]="$( uname -m )"
    [EDITOR]="$( command -v kak helix vim nano emacs | head -1 )"
    [SSH_AUTH_SOCK]="$( gpgconf --list-dirs agent-ssh-socket 2> /dev/null )"
    [SSH_AGENT_PID]="$( pgrep "gpg-agent" )"
)

# Inherit previously set $PATH from /etc/profile

declare -a OPTIONAL_PATHS=( "." "$HOME/util" "$HOME/.local/bin" )

[ -d "$HOME/games/bin" ] && OPTIONAL_PATHS+=( "$HOME/games/bin" )

[ "$( executable_exists cargo )" = 1 ] && OPTIONAL_PATHS+=( "$HOME/.cargo/bin" )

if [ "$( executable_exists luarocks )" = 1 ]; then
    OPTIONAL_PATHS+=( "$( luarocks path --lr-bin )" )

    DEFAULT_ENVIRONMENT[LUA_PATH]="$( luarocks path --lr-path )"
    DEFAULT_ENVIRONMENT[LUA_CPATH]="$( luarocks path --lr-cpath )"
fi

DEFAULT_PATH=$( echo "$PATH" | tr ":" " " )

DEFAULT_PATH+=( "${OPTIONAL_PATHS[*]}")

UNIQUE_PATH=$( echo -n "${DEFAULT_PATH[*]}" | tr ":" " " | tr " " "\n" | sort -u | tr "\n" ":" )

DEFAULT_ENVIRONMENT["PATH"]="${UNIQUE_PATH:1:-1}"

# Setup XDG_* variables if possible

if [[ -f "$( realpath -Pm "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs" )" ]]; then
    eval "$( grep -E "^[a-zA-Z_]+=\"\S+\"$" "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs" )"

    # no word-splitting guaranteed
    # shellcheck disable=2046
    export $( grep -Eo "^[a-zA-Z_]+" "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs" | tr "\n" " " )
    :
fi

for var_name in "${!DEFAULT_ENVIRONMENT[@]}"; do
    declare "$var_name"="${DEFAULT_ENVIRONMENT["$var_name"]}"
done

export "${!DEFAULT_ENVIRONMENT[@]}"

unset -v DEFAULT_ENVIRONMENT OPTIONAL_PATHS DEFAULT_PATH UNIQUE_PATH

# On login shell + Required files -> Start X

if [[ "$( is_login_shell )" = 1 ]] && [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" = 1 ]]; then
    REQUIRED_VISUAL=( "$HOME/.xinitrc" "$HOME/.xserverrc" )

    # force whitespace argument split
    # shellcheck disable=2048,2086
    [[ "$( readlink ${REQUIRED_VISUAL[*]} | wc -l )" = "${#REQUIRED_VISUAL[*]}" ]] && exec xinit
elif [[ "$( is_login_shell )" = 1 ]]; then
    exec "$( command -v tmux byobu zellij | head -1 )"
fi
