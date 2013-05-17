#include "utils.h"
program lib_constant_test
  USE_UTILS_H
  use iso_fortran_env, only: OUTPUT_UNIT, REAL64, REAL128
  use lib_comparable, only: equivalent
  use lib_constant
  
  implicit none
  
  TEST(TAB == '	')
  TEST(get_nan() /= get_nan())
  TEST(get_infinity() > huge(0.0_REAL128))
  TEST(equivalent(PI_REAL64,           3.141592653589793_REAL64))
  TEST(equivalent(RAD_FROM_DEG_REAL64, 0.017453292519943295_REAL64))
  TEST(equivalent(DEG_FROM_RAD_REAL64, 57.29577951308232_REAL64))

  write(OUTPUT_UNIT, *) "SUCCESS: ", __FILE__
  stop
end program lib_constant_test
