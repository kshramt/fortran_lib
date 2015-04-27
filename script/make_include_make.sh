#!/bin/bash

IFS=$' \t\n'

# set -xv
set -o nounset
set -o errexit
set -o pipefail
set -o noclobber

usage_and_exit(){
   {
      echo "$(basename "${0}")" '<f90-file>'
   } >&2
   exit "${1:-1}"
}


if [[ $# -ne 1 ]]; then
   usage_and_exit
fi


readonly dir="$(cd "${0%/*}"; pwd -P)"
readonly f90="$1"
readonly stem="$(basename "$f90" .f90)"


if [[ $stem =~ _lib$ ]]; then
   echo -n "$stem".o "$stem".mod: '$(call mod,'
else
   echo -n "$stem".o: '$(call mod,'
fi
"$dir"/fort_deps.sh < "$f90" | tr '\n' ' ' | sed -e 's/ $//'
echo ')'
