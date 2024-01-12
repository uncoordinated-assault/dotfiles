#!/usr/bin/env bash

exec /usr/bin/X -nolisten tcp -nolisten local "$@" "vt${XDG_VTNR}" &> /dev/null
