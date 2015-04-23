#!/bin/bash

IFS=$' \t\n'

# set -xv
set -o nounset
set -o errexit
set -o pipefail
set -o noclobber

usage_and_exit(){
   {
      echo "$(basename "${0}")" '<f90-file> <fort_deps.sh>'
   } >&2
   exit "${1:-1}"
}


if [[ $# -ne 2 ]]; then
   usage_and_exit
fi


readonly f90="$1"
readonly stem="$(basename "$f90" .f90)"
readonly fort_deps="$2"


if [[ $stem =~ _lib$ ]]; then
   echo -n "$stem".o "$stem".mod: '$(call mod,'
else
   echo -n "$stem".o: '$(call mod,'
fi
"$fort_deps" < "$f90" | tr '\n' ' ' | sed -e 's/ $//'
echo ')'
