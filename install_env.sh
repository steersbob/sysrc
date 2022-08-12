#! /usr/bin/env bash
set -euo pipefail

#    if [ -f ~/git/sysrc/env.sh ]; then
#        . ~/git/sysrc/env.sh
#    fi

FILE="$(readlink -f "$(dirname "$0")/env.sh")"

if grep -F "$FILE" ~/.bashrc; then
    echo "$FILE already mentioned in .bashrc"
    exit 0
fi

tee -a ~/.bashrc <<END

if [ -f $FILE ]; then
    . $FILE
fi

END
