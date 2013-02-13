#include "utils.h"
program lib_io_test
  use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
  use lib_io
  
  implicit none
  
  test(.false.)

  write (ERROR_UNIT, *) 'SUCCESS: ', __FILE__
  
  stop
end program lib_io_test
