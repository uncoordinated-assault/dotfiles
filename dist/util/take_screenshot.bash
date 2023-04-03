#!/usr/bin/env bash

tmp_filename="$( openssl rand -hex 4 ).png"
tmp_path="/tmp/${tmp_filename}"

flameshot gui -r > "${tmp_path}" 2> /dev/null

if [ "$( wc -l < "${tmp_path}" )" != 0 ]; then
  if scp "${tmp_path}" "wfrsk.dev:/srv/http/static/uploads/${tmp_filename}"; then
    echo "https://uploads.static.wfrsk.dev/${tmp_filename}" | xclip -selection clipboard
  fi
fi

rm -f "${tmp_path}"
