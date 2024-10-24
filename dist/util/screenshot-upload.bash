#!/usr/bin/bash

if [ "$(wl-paste | file - | grep -Eo "PNG image data" | wc -l)" != 0 ]; then

  random_name="$(openssl rand -hex 4).png"

  temporary_file="/tmp/${random_name}"

  wl-paste > "$temporary_file"

  if [ "$( wc -l < "${temporary_file}" )" != 0 ]; then
    if scp "${temporary_file}" "overtake.dev:/srv/http/static/uploads/${random_name}"; then
      target_url="https://uploads.static.overtake.dev/${random_name}"

      echo "${target_url}" | wl-copy
    fi
  fi

  rm -f "${temporary_file}"
fi
