#!/usr/bin/env bash

[ -f "$HOME/util/standard_lib.bash" ] && source "$HOME/util/standard_lib.bash"

declare -A DEFAULT_ENVIRONMENT=(
    [ARCH]="$( uname -m )"
    [EDITOR]="$( command -v helix vim nano emacs | head -1 )"
    [SSH_AUTH_SOCK]="$( gpgconf --list-dirs agent-ssh-socket 2> /dev/null )"
    [SSH_AGENT_PID]="$( pgrep "gpg-agent" )"
    [GPG_TTY]="$( tty )"

    [LIBCLANG_PATH]="/usr/local/lib"

    [visual:XDG_SESSION_TYPE]="Xorg"
)

# Inherit previously set $PATH from /etc/profile

declare -a OPTIONAL_PATHS=( "$HOME/util" "$HOME/.local/bin" )

[ -d "$HOME/games/bin" ] && OPTIONAL_PATHS+=( "$HOME/games/bin" )

[ -d "/opt/openresty/bin" ] && OPTIONAL_PATHS+=( "/opt/openresty/bin" )

[ "$( executable_exists cargo )" = 1 ] && OPTIONAL_PATHS+=( "$HOME/.cargo/bin" )

if [ "$( executable_exists luarocks )" = 1 ]; then
    OPTIONAL_PATHS+=( "$( luarocks path --lr-bin )" )

    DEFAULT_ENVIRONMENT[LUA_PATH]="$( luarocks path --lr-path )"
    DEFAULT_ENVIRONMENT[LUA_CPATH]="$( luarocks path --lr-cpath )"
fi

# shellcheck disable=2207
declare -a DEFAULT_PATH=( $( echo "$PATH" | tr ":" " " ) )

DEFAULT_PATH+=( "${OPTIONAL_PATHS[*]}" )

# shellcheck disable=2016
AWK_DUPLICATE_REMOVER='
BEGIN {
    RS = ":"
}

{
    sub(sprintf("%c$", 10), "")
    if (A[$0]) {
        # Do nothing
    } else {
        A[$0] = 1
        printf((NR == 1 ? "" : ":") $0)
    }
}
'

DEFAULT_ENVIRONMENT["PATH"]="$(echo -ne "${DEFAULT_PATH[*]}" | tr -d "\n" | tr "[:space:]" ":" | awk "$AWK_DUPLICATE_REMOVER")"

# Setup XDG_* variables if possible

if [[ -f "$( realpath -Pm "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs" )" ]]; then
    eval "$( grep -E "^[A-Z_]+=\"\S+\"$" "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs" )"

    # no word-splitting guaranteed
    # shellcheck disable=2046
    export $( grep -Eo "^[A-Z_]+" "${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs" | tr "\n" " " )
    :
fi

declare -A ENVIRONMENT_TARGETS=(
    [bare]=0
    [visual]=0
)

[[ -n "${DISPLAY}" ]] && [[ "$XDG_VTNR" != 1 ]] && ENVIRONMENT_TARGETS["bare"]=1

[[ -z "${DISPLAY}" ]] && [[ "$XDG_VTNR" = 1 ]] && ENVIRONMENT_TARGETS["visual"]=1

declare -a EXPORT_TARGETS=()

for var_name in "${!DEFAULT_ENVIRONMENT[@]}"; do
    var_value="${DEFAULT_ENVIRONMENT["$var_name"]}"

    if (
        shopt -s nocasematch;
        [[ "$var_name" =~ ^(bare|visual): ]]
    ); then
       
        var_name="$( echo "$var_name" | grep -Po "(?i)^(bare|visual):\K([a-z_][a-z_0-9]*)$" )"
        
        EXPORT_TARGETS+=( "$var_name" )
       
        if (
            shopt -s nocasematch;
            [[ "$var_name" =~ ^bare: ]]
        ) && [[ "${ENVIRONMENT_TARGETS["bare"]}" = 1 ]]; then
            declare "${var_name}=${var_value}"
        elif (
            shopt -s nocasematch;
            [[ "$var_name" =~ ^visual: ]]
        ) && [[ "${ENVIRONMENT_TARGETS["visual"]}" = 1 ]]; then
            declare "${var_name}=${var_value}"
        fi
    else
        EXPORT_TARGETS+=( "$var_name" )

        declare "${var_name}=${var_value}"
    fi
done

export "${EXPORT_TARGETS[@]}"

# Dynamic initialization process

# -> Add secret authentication subkeys to .gnupg/sshcontrol automatically

# shellcheck disable=2207
declare -a keygrip_list=( $( gpg -K --with-keygrip | grep -P -A1 "\[.*A.*\]$" | grep -Po "^\s+Keygrip\s+=\s+\K([0-9A-F]+)$" | tr "\n" " " ) )

mkdir -vp "$HOME/.gnupg"

touch "$HOME/.gnupg/sshcontrol"

for keygrip in "${keygrip_list[@]}"; do
    if ! grep -q "$keygrip" "$HOME/.gnupg/sshcontrol"; then
        printf "%s 300\n" "$keygrip" >> "$HOME/.gnupg/sshcontrol" 
    fi
done

# -> Start libinput-gestures
systemctl --user start libinput-gestures

# On login shell (asummed) + Required files -> Start visual session

if [[ "${ENVIRONMENT_TARGETS["visual"]}" = 1 ]]; then   
    exec Hyprland > "$HOME/.hyprland.log" 2>&1
elif [[ -n "$SSH_CONNECTION" ]] || [[ -n "$TERMUX_VERSION" ]]; then
    exec bash
else
    exec tmux new "-As${USER:-default}"
fi
