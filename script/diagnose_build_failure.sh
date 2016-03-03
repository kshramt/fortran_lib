#!/bin/bash


usage_and_exit(){
   {
      echo "CPP=/path/to/cpp ERB=/path/to/erb FC=/path/to/gfortran MAKE=/path/to/make RUBY=/path/to/ruby ${0##*/}" '2>&1 | tee fortran_lib.log'
   } >&2
   exit "${1:-1}"
}


if [[ $# -ne 0 ]]; then
   usage_and_exit
fi


set -xv
/bin/bash --version


set -o nounset
set -o errexit
set -o pipefail
set -o noclobber

export IFS=$' \t\n'
export LANG=en_US.UTF-8
umask u=rwx,g=,o=

readonly dir="${0%/*}"
readonly tmp_dir="$(mktemp -d)"

finalize(){
   : You can rm -fr "$tmp_dir"
}

trap finalize EXIT


cd "$tmp_dir"

: CPP="${CPP:=cpp}"
: ERB="${ERB:=erb}"
: FC="${FC:=gfortran}"
: MAKE="${MAKE:=make}"
: RUBY="${RUBY:=ruby}"


"$CPP" --version
"$ERB" --version
"$FC" --version
"$MAKE" --version
"$RUBY" --version
git --version


git clone https://github.com/kshramt/fortran_lib.git
cd fortran_lib


"$MAKE" CPP="$CPP" ERB="$ERB" FC="$FC" RUBY="$RUBY"


bin/etas_solve.sh \
   --t_normalize_len=1 \
   --m_for_K=6 \
   --t_pre=0 \
   --t_begin=0 \
   --t_end=1000 \
   --data_file=example/etas_solve/catalog.tsv |
   release/bin/etas_solve.exe
