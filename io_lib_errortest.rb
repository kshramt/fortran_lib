$dependencies << 'character_lib.o'
$dependencies << 'io_lib.o'
$dependencies << 'config_lib.o'
$compiler = ENV.fetch('MY_FORTRAN_DEBUG', 'gfortran -ffree-line-length-none -fmax-identifier-length=63 -pipe -cpp -C -Wall -fbounds-check -O0 -fbacktrace -ggdb -pg -DDEBUG')

setup <<-EOS
# include "../fortran_lib.h"
program runner
  USE_FORTRAN_LIB_H
  use, non_intrinsic:: io_lib

  implicit none

  Integer:: io
EOS

errortest 'Illegal form argument', "call mktemp(io, form = 'illegal')"

teardown <<-EOS
  stop
end program runner
EOS
