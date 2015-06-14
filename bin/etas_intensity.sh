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
      echo "seq 0 0.01 7 | $program_name" '--t_normalization=1 --m_for_K=7 --c=1 --p=1 --alpha=1 --K=1 --mu=1 --data_file=path/to/data_file | path/to/etas_intensity.exe'
   } >&2
   exit "${1:-1}"
}

readonly dir="${0%/*}"


opts="$(
   getopt \
      --options h \
      --longoptions help,t_normalization:,m_for_K:,c:,p:,alpha:,K:,mu:,data_file: \
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
      --t_normalization)
         t_normalization="$2"
         shift
         ;;
      --m_for_K)
         m_for_K="$2"
         shift
         ;;
      --c)
         c="$2"
         shift
         ;;
      --p)
         p="$2"
         shift
         ;;
      --alpha)
         alpha="$2"
         shift
         ;;
      --K)
         K="$2"
         shift
         ;;
      --mu)
         mu="$2"
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
[[ -z "${c:-}" ]] && { echo 'c not specified' >&2 ; usage_and_exit ; }
[[ -z "${p:-}" ]] && { echo 'p not specified' >&2 ; usage_and_exit ; }
[[ -z "${alpha:-}" ]] && { echo 'alpha not specified' >&2 ; usage_and_exit ; }
[[ -z "${K:-}" ]] && { echo 'K not specified' >&2 ; usage_and_exit ; }
[[ -z "${mu:-}" ]] && { echo 'mu not specified' >&2 ; usage_and_exit ; }
[[ -z "${data_file:-}" ]] && { echo 'data_file not specified' >&2 ; usage_and_exit ; }


echo "$t_normalization"
echo "$m_for_K"
echo "$c" "$p" "$alpha" "$K" "$mu"
wc -l "$data_file" | awk '{print $1}'
cat "$data_file"
cat
