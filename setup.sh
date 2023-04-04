#!/usr/bin/env bash

SETUP_MODE="${1:-bare}"

case "$SETUP_MODE" in
    "bare"|"visual")
        :
        ;;
    *)
        printf "E: unknown setup mode \`%s\`" "$SETUP_MODE"
        exit 1
        ;;
esac

CURRENT_FILE="$( pwd -L )/${0}"
CURRENT_DIRECTORY=$( dirname "$CURRENT_FILE" )

[ -f "$CURRENT_DIRECTORY/dist/util/standard_lib.bash" ] && source "$CURRENT_DIRECTORY/dist/util/standard_lib.bash"

# Associative array indicating the symlinks for the `bare` setup mode
declare -A SYMLINK_TARGETS_BARE=(
    ["$HOME/.bash_profile"]="dist/config/bare/setup_env.bash"
    ["$HOME/.bashrc"]="dist/config/bare/setup_shell.bash"

    ["$HOME/.tmux.conf"]="dist/config/bare/app/tmux.config"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"]="dist/config/bare/app/starship_config.toml"

    ["$HOME/util"]="dist/util"
)

# Associative array indicating the symlinks for the `visual` setup mode
declare -A SYMLINK_TARGETS_VISUAL=(
    ["$HOME/.xinitrc"]="dist/config/visual/setup_desktop.bash"
    ["$HOME/.xserverrc"]="dist/config/visual/setup_server.bash"

    ["$HOME/.i3wm"]="dist/config/visual/app/i3wm.config"

    ["$HOME/.picom"]="dist/config/visual/app/picom.config"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs"]="dist/config/visual/app/common_directories.config"

    ["$HOME/.alacritty.yaml"]="dist/config/visual/app/alacritty.config.yaml"
    ["$HOME/.alacritty.theme.yaml"]="dist/config/visual/app/alacritty.theme.yaml"

    ["$HOME/.rofi"]="dist/config/visual/app/rofi.config"
    ["$HOME/.rofi_themes"]="dist/config/visual/app/rofi_themes"
)

# Inherit from `bare` setup for `visual` setup
# shellcheck disable=2034
for var_name in "${!SYMLINK_TARGETS_BARE[@]}"; do
    SYMLINK_TARGETS_VISUAL["$var_name"]="${SYMLINK_TARGETS_BARE["$var_name"]}"
done

# create a reference to our desired associated array
# shellcheck disable=2155
declare -n SYMLINK_TARGETS="SYMLINK_TARGETS_$( echo "$SETUP_MODE" | tr "[:lower:]" "[:upper:]" )"

for symlink_path in "${!SYMLINK_TARGETS[@]}"; do
    resource_path="${SYMLINK_TARGETS["$symlink_path"]}"
    symlink_dirname="$( dirname "$symlink_path" )"

    # Create paremt directories for the symlink path
    mkdir -vp "$symlink_dirname"

    symlink_contents="$( relative_to "$symlink_dirname" "${CURRENT_DIRECTORY}/${resource_path}" )"

    # If we are dealing with an already existing symlink and it doesn't point to our resource file, proceed to delete it
    # but if an already existing symlink points to our resource file, do nothing
    if [[ "$( readlink "$symlink_path" | wc -l )" != 0 ]]; then
        if [[ "$( readlink "$symlink_path" )" != "$symlink_contents" ]]; then
            rm -rf "$symlink_path"
        else
            printf "skipped \`%s\` due to existing link\n" "$symlink_path"
            continue
        fi
        :
    fi

    # Perform the link, backing up existing files if possible
    ln -S "old" -sbfv "$symlink_contents" "$symlink_path"
done

# no word-splitting guaranteed
# shellcheck disable=2046
unset -v SETUP_MODE CURRENT_FILE CURRENT_DIRECTORY SYMLINK_TARGETS $( compgen -v | grep -Eo "^SYMLINK_TARGETS_[A-Z]+$" | tr "\n" " " )
