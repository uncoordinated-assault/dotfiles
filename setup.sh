#!/usr/bin/env bash

SETUP_MODE="${1:-bare}"

case "$SETUP_MODE" in
"bare" | "visual")
    :
    ;;
"clean")

    read -rp "Are you sure you want to delete all 'active.*' files? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        find . -type f -name 'active.*' -exec printf '{}\n' \; | xargs -I {} rm {}
    else
        echo "Operation cancelled."
    fi
    exit
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

CURRENT_FILE="$(pwd -L)/${0}"
CURRENT_DIRECTORY=$(dirname "$CURRENT_FILE")

[ -f "$CURRENT_DIRECTORY/dist/util/standard-lib.bash" ] && source "$CURRENT_DIRECTORY/dist/util/standard-lib.bash"

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
    ["user:$HOME/.visual"]="dist/config/visual/user"

    ["$HOME/.wallpaper"]="dist/wallpaper"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/waybar/config"]="dist/config/visual/app/waybar.config"
    ["${XDG_CONFIG_HOME:-$HOME/.config}/waybar/style.css"]="dist/config/visual/app/waybar-style.css"

    ["${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.conf"]="dist/config/visual/app/hyprland.config"
    ["${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hypridle.conf"]="dist/config/visual/app/hypridle.config"

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
declare -n SYMLINK_TARGETS="SYMLINK_TARGETS_$(echo "$SETUP_MODE" | tr "[:lower:]" "[:upper:]")"

for target_dest in "${!SYMLINK_TARGETS[@]}"; do
    target_resource="${SYMLINK_TARGETS["$target_dest"]}"

    # check if the resource has an install modifier
    install_mod="none"

    {
        shopt -s nocasematch

        if [[ "$target_dest" =~ ^([a-z]+):(.+)$ ]]; then
            # set the modifier accordingly
            install_mod="${BASH_REMATCH[1]}"

            # update destination to the actual path
            target_dest="${BASH_REMATCH[2]}"

            case "$install_mod" in
            "user") ;;
            *)
                printf "E: unknown install modifier \`%s\` for path \`%s\`\n" "$install_mod" "$target_dest"
                exit 1
                ;;
            esac
        fi

        shopt -u nocasematch
    }

    target_dirname="$(dirname "$target_dest")"

    # Create parent directories for the symlink path
    mkdir -vp "$target_dirname"

    symlink_contents="$(relative_to "$target_dirname" "${CURRENT_DIRECTORY}/${target_resource}")"

    # If we are dealing with an already existing symlink and it doesn't point to our resource file, proceed to delete it
    # but if an already existing symlink points to our resource file, do nothing
    if [[ "$(readlink "$target_dest" | wc -l)" != 0 ]]; then
        if [[ "$(readlink "$target_dest")" = "$symlink_contents" ]]; then
            printf "target: \`%s\` already existing link\n" "$target_dest"
        fi

        rm "$target_dest"
    fi

    # Do a backup if $target_dest is either a file or a directory
    if [[ -e "$target_dest" ]]; then
        mv "$target_dest" "${target_dest}~"
    fi

    # Perform the link
    ln -sfv "$symlink_contents" "$target_dest"

    case "$install_mod" in
    "user")
        # the folder is symlinked now, but we need to setup the base candidates as active ones

        base_candidates="$(find "${CURRENT_DIRECTORY}/${target_resource}" -type f -name "base.*")"

        for base_candidate in $base_candidates; do
            printf "base candidate: %s\n" "$base_candidate"

            candidate_location="$(dirname "$base_candidate")"

            printf "base candidate location: %s\n" "$candidate_location"

            candidate_name="$(basename "$base_candidate")"
            candidate_name="${candidate_name/base./}"

            active_candidate_name="$(printf "active.%s" "$candidate_name")"

            echo "active candidate: $active_candidate_name"

            active_candidate="${candidate_location}/${active_candidate_name}"

            if [[ ! -e "$active_candidate" ]]; then
                cp -rv "$base_candidate" "${active_candidate}"

                sed -i 's/base\./active\./g' "${active_candidate}"
            else
                printf "active candidate already exists: %s; skipping\n" "$active_candidate"
            fi
        done
        ;;
    "none")
        # do nothing
        :
        ;;
    *)
        printf "E: unknown install modifier \`%s\` for path \`%s\`\n" "$install_mod" "$target_dest"
        exit 1
        ;;
    esac

    :
done

# for symlink_path in "${!SYMLINK_TARGETS[@]}"; do
#     resource_path="${SYMLINK_TARGETS["$symlink_path"]}"
#     symlink_dirname="$( dirname "$symlink_path" )"

#     # Create parent directories for the symlink path
#     mkdir -vp "$symlink_dirname"

#     symlink_contents="$( relative_to "$symlink_dirname" "${CURRENT_DIRECTORY}/${resource_path}" )"

#     if [[ "$SETUP_MODE" = "system" ]]; then
#         cp -bvr "$resource_path" "$symlink_path"

#         continue
#     fi

#     # If we are dealing with an already existing symlink and it doesn't point to our resource file, proceed to delete it
#     # but if an already existing symlink points to our resource file, do nothing
#     if [[ "$( readlink "$symlink_path" | wc -l )" != 0 ]]; then
#         if [[ "$( readlink "$symlink_path" )" != "$symlink_contents" ]]; then
#             rm -rf "$symlink_path"
#         else
#             printf "skipped \`%s\` due to existing link\n" "$symlink_path"
#             continue
#         fi
#     fi

#     # Do a backup if $symlink_path is either a file or a directory
#     if [[ -e "$symlink_path" ]]; then
#         mv "$symlink_path" "${symlink_path}~"
#     fi

#     # Perform the link
#     ln -sfv "$symlink_contents" "$symlink_path"
# done

# no word-splitting guaranteed
# shellcheck disable=2046
unset -v SETUP_MODE CURRENT_FILE CURRENT_DIRECTORY SYMLINK_TARGETS $(compgen -v | grep -Eo "^SYMLINK_TARGETS_[A-Z]+$" | tr "\n" " ")
