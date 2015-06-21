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
$program_name [options] --t_normalize_len=1 --m_for_K=7 --t_pre=0 --t_begin=10 --t_end=60 --c=0.01 --p=1 --alpha=1 --K=10 --mu=1 --data_file=path/to/data_file | path/to/etas_solve.exe
# c, p, alpha, K, mu:
# Initial values.
#
# t_pre, t_begin, t_end:
# t_pre <= t_begin <= t_end.
# Earthquakes in [t_begin, t_end] are fitted by etas_solve.exe.
# Earthquakes in [t_pre, t_begin) are not fitted although intensities from them to earthquakes in [t_begin, t_end] are considered.
#
# data_file:
# The first column should be time, and the second column should be magnitude.
# Time should be sorted in ascending order.
# The first time should be later than or equal to t_pre.
# The last time should be faster than or equal to t_end.
#
# m_for_K:
# Reference magnitude.
#
# t_normalize_len:
# Normalization time interval.
# Background intensity produces mu earthquakes per t_normalize_len on average.
# A M == m_for_K earthquake produces K direct aftershocks per t_normalize_len, on average.
#
# [options]:
#
# mask[=t,t,t,t,t]:
# If you want to fix alpha by the initial value while performing optimization, please try --mask=t,t,f,t,t.
#
# lower_bounds[=1d-8,-1,-1,0,1d-8]:
# Lower bounds of the ETAS parameters.
#
# upper_bounds[=1d308,30,10,1d308,1d308]:
# Upper bounds of the ETAS parameters.
EOF
   } >&2
   exit "${1:-1}"
}

readonly dir="${0%/*}"


opts="$(
   getopt \
      --options h \
      --longoptions help,t_pre:,t_begin:,t_end:,t_normalize_len:,m_for_K:,c:,p:,alpha:,K:,mu:,data_file:,mask:,lower_bounds:,upper_bounds: \
      --name="$program_name" \
      -- \
      "$@"
)"
eval set -- "$opts"

mask=t,t,t,t,t
lower_bounds=1d-8,-1,-1,0,1d-8
upper_bounds=1d308,30,10,1d308,1d308
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
      --t_begin)
         t_begin="$2"
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
      --mask)
         mask="$2"
         shift
         ;;
      --lower_bounds)
         lower_bounds="$2"
         shift
         ;;
      --upper_bounds)
         upper_bounds="$2"
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


[[ -z "${t_normalize_len:-}" ]] && { echo 't_normalize_len not specified' >&2 ; usage_and_exit ; }
[[ -z "${m_for_K:-}" ]] && { echo 'm_for_K not specified' >&2 ; usage_and_exit ; }
[[ -z "${t_pre:-}" ]] && { echo 't_pre not specified' >&2 ; usage_and_exit ; }
[[ -z "${t_begin:-}" ]] && { echo 't_begin not specified' >&2 ; usage_and_exit ; }
[[ -z "${t_end:-}" ]] && { echo 't_end not specified' >&2 ; usage_and_exit ; }
[[ -z "${c:-}" ]] && { echo 'c not specified' >&2 ; usage_and_exit ; }
[[ -z "${p:-}" ]] && { echo 'p not specified' >&2 ; usage_and_exit ; }
[[ -z "${alpha:-}" ]] && { echo 'alpha not specified' >&2 ; usage_and_exit ; }
[[ -z "${K:-}" ]] && { echo 'K not specified' >&2 ; usage_and_exit ; }
[[ -z "${mu:-}" ]] && { echo 'mu not specified' >&2 ; usage_and_exit ; }
[[ -z "${data_file:-}" ]] && { echo 'data_file not specified' >&2 ; usage_and_exit ; }


echo "$mask"
echo "$c" "$p" "$alpha" "$K" "$mu"
echo "$lower_bounds"
echo "$upper_bounds"
echo "$t_begin"
echo "$m_for_K"
echo "$t_normalize_len"
echo "$t_pre"
echo "$t_end"
wc -l "$data_file" | awk '{print $1}'
cat "$data_file"
