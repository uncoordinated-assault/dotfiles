#!/usr/bin/env bash

target_action="$1"

case "$target_action" in
*toggle)
    if [[ "$(bluetoothctl show | grep  -Po "Powered:\\s+yes" | wc -l)" = 1 ]]; then
        bluetoothctl power off
    else
        bluetoothctl power on
    fi
    ;;
esac
