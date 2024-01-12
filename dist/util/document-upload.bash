#!/usr/bin/bash

random_name="$(openssl rand -hex 4).${1}"

temporary_file="/tmp/${random_name}"

cat - > "$temporary_file"

cat "$temporary_file" | wl-copy

if [ "$( wc -l < "${temporary_file}" )" != 0 ]; then
  if scp "${temporary_file}" "overtake.dev:/srv/http/static/uploads/${random_name}"; then
    echo "https://uploads.static.overtake.dev/${random_name}" | wl-copy
  fi
fi

rm -f "${temporary_file}"
