#include "utils.h"
program lib_reflectable_test
  USE_UTILS_H
  use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT, REAL32
  use lib_reflectable

  implicit none
  
  test(stem_from_type(0.0) == 'Real')
  test(dim_from_type(0.0) == 0)
  test(kind_from_type(0.0) == REAL32)
  test(str_from_type(0.0) == 'RealDim0KindREAL32')

  write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__
  stop
end program lib_reflectable_test
