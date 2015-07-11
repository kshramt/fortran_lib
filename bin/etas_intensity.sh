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
      echo "seq 0 0.01 7 | $program_name" '--t_normalize_len=1 --m_for_K=6 --mu=1 --K=1 --c=1 --alpha=1 --p=1 --data_file=path/to/data_file | path/to/etas_intensity.exe'
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
      --longoptions help,t_normalize_len:,m_for_K:,mu:,K:,c:,alpha:,p:,data_file: \
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
      --t_normalize_len)
         t_normalize_len="$2"
         shift
         ;;
      --m_for_K)
         m_for_K="$2"
         shift
         ;;
      --mu)
         mu="$2"
         shift
            ;;
      --K)
         K="$2"
         shift
         ;;
      --c)
         c="$2"
         shift
         ;;
      --alpha)
         alpha="$2"
         shift
         ;;
      --p)
         p="$2"
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
[[ -z "${mu:-}" ]] && option_missing --mu
[[ -z "${K:-}" ]] && option_missing --K
[[ -z "${c:-}" ]] && option_missing --c
[[ -z "${alpha:-}" ]] && option_missing --alpha
[[ -z "${p:-}" ]] && option_missing --p
[[ -z "${data_file:-}" ]] && option_missing --data_file


echo "$t_normalize_len"
echo "$m_for_K"
echo "$mu" "$K" "$c" "$alpha" "$p"
wc -l "$data_file" | awk '{print $1}'
cat "$data_file"
cat
