#!/usr/bin/bash

# shellcheck disable=2207
AVAILABLE_GOVERNORS=( "performance" "powersave" "schedutil" )

GOVERNOR_SELECTION="$( echo -ne "${AVAILABLE_GOVERNORS[@]}" | tr "[:space:]" "\n" | rofi -dmenu )"

# Requires rofi command output.
# shellcheck disable=2181
if [[ "$?" = 0 ]]; then
  pkexec cpupower frequency-set -g "$GOVERNOR_SELECTION"
fi
