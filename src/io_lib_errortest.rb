$dependencies << 'character_lib.o'
$dependencies << 'io_lib.o'
$compiler = ENV.fetch('MY_FORTRAN_DEBUG', 'gfortran -ffree-line-length-none -fmax-identifier-length=63 -pipe -cpp -C -Wall -fbounds-check -O0 -fbacktrace -ggdb -pg -DDEBUG')

setup <<-EOS
# include "../utils.h"
program runner
  USE_UTILS_H
  use, non_intrinsic:: io_lib

  implicit none

  Integer:: io
EOS

errortest 'Illegal form argument', "call mktemp(io, form = 'illegal')"

teardown <<-EOS
  stop
end program runner
EOS
