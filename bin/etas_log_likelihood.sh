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
      cat <<EOF
$program_name --t_normalize_len=1 --m_for_K=6 --t_pre=0 --t_end=60 --data_file=path/to/data_file < path/to/etas_parameters | path/to/etas_log_likelihood.exe

If you want to interact with data as a neural network based optimizer, rlwrap may be useful:
rlwrap $program_name --t_normalize_len=1 --m_for_K=6 --t_pre=0 --t_end=60 --data_file=path/to/data_file | path/to/etas_log_likelihood.exe

etas_parameters should contain following 8 columns:
m_fit_min t_begin t_end c p alpha K mu
EOF
   } >&2
   exit "${1:-1}"
}

option_missing(){
   {
      cat <<EOF
${program_name}: $@ was not specified
EOF
   } >&2
   exit 1
}

readonly dir="${0%/*}"


opts="$(
   getopt \
      --options h \
      --longoptions help,t_pre:,t_end:,t_normalize_len:,m_for_K:,data_file: \
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
      --t_pre)
         t_pre="$2"
         shift
         ;;
      --t_end)
         t_end="$2"
         shift
         ;;
      --t_normalize_len)
         t_normalize_len="$2"
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


[[ -z "${t_normalize_len:-}" ]] && option_missing --t_normalize_len
[[ -z "${m_for_K:-}" ]] && option_missing --m_for_K
[[ -z "${t_pre:-}" ]] && option_missing --t_pre
[[ -z "${t_end:-}" ]] && option_missing --t_end
[[ -z "${data_file:-}" ]] && option_missing --data_file


echo "$m_for_K"
echo "$t_normalize_len"
echo "$t_pre"
echo "$t_end"
wc -l "$data_file" | awk '{print $1}'
cat "$data_file"
cat
