#!/bin/bash

IFS=$' \t\n'

# set -xv
set -o nounset
set -o errexit
set -o pipefail
set -o noclobber

readonly program_name="${0##*/}"
usage_and_exit(){
   {
      echo "$program_name" '--t_normalization=1 --m_for_K=7 --t_begin=0 --t_pad=10 --t_end=60 --data_file=path/to/data_file < /path/to/etas_parameters | path/to/etas_log_likelihood.exe'
   } >&2
   exit "${1:-1}"
}

readonly dir="${0%/*}"


opts="$(
   getopt \
      --options h \
      --longoptions help,t_begin:,t_end:,t_pad:,t_normalization:,m_for_K:,data_file: \
      --name="$program_name" \
      -- \
      "$@"
)"
eval set -- "$opts"

while true
do
   case "${1}" in
      -h | --help)
         usage_and_exit 0
         ;;
      --t_begin)
         t_begin="$2"
         shift
         ;;
      --t_pad)
         t_pad="$2"
         shift
         ;;
      --t_end)
         t_end="$2"
         shift
         ;;
      --t_normalization)
         t_normalization="$2"
         shift
         ;;
      --m_for_K)
         m_for_K="$2"
         shift
         ;;
      --data_file)
         data_file="$2"
         shift
         ;;
      --)
         shift
         break
         ;;
      *)
         usage_and_exit
         ;;
   esac
   shift
done


[[ -z "${t_normalization:-}" ]] && { echo 't_normalization not specified' >&2 ; usage_and_exit ; }
[[ -z "${m_for_K:-}" ]] && { echo 'm_for_K not specified' >&2 ; usage_and_exit ; }
[[ -z "${t_begin:-}" ]] && { echo 't_begin not specified' >&2 ; usage_and_exit ; }
[[ -z "${t_pad:-}" ]] && { echo 't_pad not specified' >&2 ; usage_and_exit ; }
[[ -z "${t_end:-}" ]] && { echo 't_end not specified' >&2 ; usage_and_exit ; }
[[ -z "${data_file:-}" ]] && { echo 'data_file not specified' >&2 ; usage_and_exit ; }


echo "$m_for_K"
echo "$t_normalize_len"
echo "$t_begin"
echo "$t_pad"
echo "$t_end"
wc -l "$data_file" | awk '{print $1}'
cat "$data_file"
cat
