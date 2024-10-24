#!/usr/bin/bash

if [ "$(wl-paste | file - | grep -Eo "PNG image data" | wc -l)" != 0 ]; then
  wl-paste | swappy -f -  
fi
