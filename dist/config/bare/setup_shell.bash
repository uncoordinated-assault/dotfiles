#!/usr/bin/env bash

[ -f "$HOME/util/standard_lib.bash" ] && source "$HOME/util/standard_lib.bash"

# Fallback to simple shell if `starship` is not installed

if [[ "$( executable_exists starship )" != 0 ]]; then
    eval "$(starship init bash)"
else
    PS1='\[\e[0m\][\[\e[0m\]\u\[\e[0m\]]\[\e[0m\][\[\e[0m\]\W\[\e[0m\]]\n\[\e[0m\]> \[\e[0m\]'
fi
