#!/bin/bash

IFS=$' \t\n'

# set -xv
set -o nounset
set -o errexit
set -o pipefail
set -o noclobber

usage_and_exit(){
   {
      echo "$(basename "${0}")" '<f90-file> <base_dir>'
   } >&2
   exit "${1:-1}"
}


if [[ $# -ne 2 ]]; then
   usage_and_exit
fi


readonly dir="${0%/*}"
readonly f90="$1"
readonly stem="$(basename "$f90" .f90)"
readonly base_dir="$2"


if [[ $stem =~ _lib$ ]]; then
   echo -n "$base_dir/$stem".o "$base_dir/$stem".mod: '$(call '"mod_$base_dir"','
else
   echo -n "$base_dir/$stem".o: '$(call '"mod_$base_dir"','
fi
"$dir"/fort_deps.sh < "$f90" | tr '\n' ' ' | sed -e 's/ $//'
echo ')'
