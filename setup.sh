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

if [ "$EUID" != 0 ] && [ "$SETUP_MODE" = "system" ]; then
    printf "E: setup mode \`%s\` requires root privileges\n" "$SETUP_MODE"

    exit 1
fi

CURRENT_FILE="$( pwd -L )/${0}"
CURRENT_DIRECTORY=$( dirname "$CURRENT_FILE" )

[ -f "$CURRENT_DIRECTORY/dist/util/standard_lib.bash" ] && source "$CURRENT_DIRECTORY/dist/util/standard_lib.bash"


# Associative array indicating the symlinks for the `bare` setup mode
declare -A SYMLINK_TARGETS_BARE=(
    ["$HOME/.bash_profile"]="dist/config/bare/setup-env.bash"
    ["$HOME/.bashrc"]="dist/config/bare/setup-shell.bash"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs"]="dist/config/bare/app/common-directories.config"

    ["$HOME/.tmux.conf"]="dist/config/bare/app/tmux.config"

    ["$HOME/.ssh/config"]="dist/config/bare/app/ssh.config"

    ["$HOME/.gnupg/gpg-agent.conf"]="dist/config/bare/app/gpg-agent.config"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"]="dist/config/bare/app/starship-config.toml"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/helix/config.toml"]="dist/config/bare/app/helix-config.toml"

    ["$HOME/util"]="dist/util"

    ["$HOME/.tmux/plugins/tpm"]="dist/config/bare/app/tmux-tpm"
)

# Associative array indicating the symlinks for the `visual` setup mode
declare -A SYMLINK_TARGETS_VISUAL=(
    ["${XDG_CONFIG_HOME:-$HOME/.config}/waybar/config"]="dist/config/visual/app/waybar.config"
    ["${XDG_CONFIG_HOME:-$HOME/.config}/waybar/style.css"]="dist/config/visual/app/waybar-style.css"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.conf"]="dist/config/visual/app/hyprland.config"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/hypr/themes"]="dist/config/visual/app/hyprland-themes"


    ["$HOME/.alacritty.toml"]="dist/config/visual/app/alacritty.config.toml"
    ["$HOME/.alacritty.theme.toml"]="dist/config/visual/app/alacritty.theme.toml"
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

    # Create parent directories for the symlink path
    mkdir -vp "$symlink_dirname"

    symlink_contents="$( relative_to "$symlink_dirname" "${CURRENT_DIRECTORY}/${resource_path}" )"

    if [[ "$SETUP_MODE" = "system" ]]; then
        cp -bvr "$resource_path" "$symlink_path"

        continue
    fi

    # If we are dealing with an already existing symlink and it doesn't point to our resource file, proceed to delete it
    # but if an already existing symlink points to our resource file, do nothing
    if [[ "$( readlink "$symlink_path" | wc -l )" != 0 ]]; then
        if [[ "$( readlink "$symlink_path" )" != "$symlink_contents" ]]; then
            rm -rf "$symlink_path"
        else
            printf "skipped \`%s\` due to existing link\n" "$symlink_path"
            continue
        fi
    fi

    # Do a backup if $symlink_path is either a file or a directory
    if [[ -e "$symlink_path" ]]; then
        mv "$symlink_path" "${symlink_path}~"
    fi

    # Perform the link
    ln -sfv "$symlink_contents" "$symlink_path"
done

# no word-splitting guaranteed
# shellcheck disable=2046
unset -v SETUP_MODE CURRENT_FILE CURRENT_DIRECTORY SYMLINK_TARGETS $( compgen -v | grep -Eo "^SYMLINK_TARGETS_[A-Z]+$" | tr "\n" " " )
