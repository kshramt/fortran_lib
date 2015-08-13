#!/bin/bash

IFS=$' \t\n'
umask u=rwx,g=,o=


# set -xv
set -o nounset
set -o errexit
set -o pipefail
set -o noclobber

usage_and_exit(){
   {
      echo "${0##*/}" '<exe>'
   } >&2
   exit "${1:-1}"
}


if [[ $# -ne 1 ]]; then
   usage_and_exit
fi


exe="$1"


n="$(echo -1 | "$exe")"


for i in $(seq "$n")
do
   ! "$exe" < <(echo "$i")
done


echo SUCCESS: "$exe"
