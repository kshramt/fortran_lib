#!/bin/bash

IFS=$' \t\n'

# set -xv
set -o nounset
set -o errexit
set -o pipefail
set -o noclobber

usage_and_exit(){
   {
      echo '# overwrite <file2> by <file1> if they differ'
      echo '# <file1>/<file2> should not be a stream'
      echo "$(basename "${0}")" '<file1> <file2>'
   } >&2
   exit "${1:-1}"
}


if [[ $# -ne 2 ]]; then
   usage_and_exit
fi


if ! cmp -s "$1" "$2"; then
   mkdir -p "$(dirname "$2")"
   cat "$1" >| "$2"
fi
