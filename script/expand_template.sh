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
      echo "${0##*/}" '<params_file> <template_file> <module_name>'
   } >&2
   exit "${1:-1}"
}


if [[ $# -ne 3 ]]; then
   usage_and_exit
fi


readonly params_file="$1"
readonly template_file="$2"
readonly module_name="$3"


{
   echo "$module_name"
   cat "$params_file"
} | $ERB $ERB_FLAGS "$template_file"
