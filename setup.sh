#!/usr/bin/env bash

SETUP_MODE="${1:-bare}"

case "$SETUP_MODE" in
    "bare"|"visual"|"system")
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

# shellcheck disable=2034
declare -A SYMLINK_TARGETS_SYSTEM=(
    ["/etc/kernel/cmdline"]="dist/config/system/kernel/cmdline"

    ["/etc/mkinitcpio.conf"]="dist/config/system/kernel/mkinitcpio.config"

    ["/etc/modprobe.d/amdgpu.conf"]="dist/config/system/kernel/amdgpu.config"

    ["/etc/modprobe.d/disable-webcam.conf"]="dist/config/system/kernel/disable-webcam.config"

    ["/etc/vconsole.conf"]="dist/config/system/vconsole.config"

    ["/etc/kmscon/kmscon.conf"]="dist/config/system/kmscon.config"
)

# Associative array indicating the symlinks for the `bare` setup mode
declare -A SYMLINK_TARGETS_BARE=(
    ["$HOME/.bash_profile"]="dist/config/bare/setup_env.bash"
    ["$HOME/.bashrc"]="dist/config/bare/setup_shell.bash"

    ["$HOME/.tmux.conf"]="dist/config/bare/app/tmux.config"

    ["$HOME/.ssh/config"]="dist/config/bare/app/ssh.config"

    ["$HOME/.gnupg/gpg-agent.conf"]="dist/config/bare/app/gpg-agent.config"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"]="dist/config/bare/app/starship_config.toml"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/helix/config.toml"]="dist/config/bare/app/helix_config.toml"

    ["$HOME/util"]="dist/util"
)

# Associative array indicating the symlinks for the `visual` setup mode
declare -A SYMLINK_TARGETS_VISUAL=(
    ["$HOME/.xinitrc"]="dist/config/visual/setup_desktop.bash"
    ["$HOME/.xserverrc"]="dist/config/visual/setup_server.bash"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/polybar/config.ini"]="dist/config/visual/app/polybar.config"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.conf"]="dist/config/visual/app/hyprland.config"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/hypr/themes"]="dist/config/visual/app/hyprland-themes"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/i3/config"]="dist/config/visual/app/i3wm.config"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/libinput-gestures.service.d/env-override.conf"]="dist/config/visual/app/libinput-gestures.override"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/libinput-gestures.conf"]="dist/config/visual/app/libinput-gestures.config"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/picom/picom.conf"]="dist/config/visual/app/picom.config"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs"]="dist/config/visual/app/common_directories.config"

    ["$HOME/.alacritty.toml"]="dist/config/visual/app/alacritty.config.toml"
    ["$HOME/.alacritty.theme.toml"]="dist/config/visual/app/alacritty.theme.toml"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/rofi/config.rasi"]="dist/config/visual/app/rofi.config"
    ["${XDG_CONFIG_HOME:-$HOME/.config}/rofi/themes"]="dist/config/visual/app/rofi_themes"
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
