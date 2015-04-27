#!/bin/bash

IFS=$' \t\n'

# set -xv
set -o nounset
set -o errexit
set -o pipefail
set -o noclobber

usage_and_exit(){
   {
      echo "$(basename "${0}")" '< <f90-file>'
   } >&2
   exit "${1:-1}"
}


if [[ $# -ne 0 ]]; then
   usage_and_exit
fi


{ grep '^ *use, non_intrinsic::' || : ; } |
   awk '{print $3}' |
   { grep -v ifport || : ; } |
   sed -e 's/,$//' |
   sort -u
