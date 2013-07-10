#include "utils.h"
program constant_lib_test
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: OUTPUT_UNIT, REAL64, REAL128
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: constant_lib
   
   implicit none
   
   TEST(TAB == '	')
   TEST(get_nan() /= get_nan())
   TEST(get_infinity() > huge(0.0_REAL128))
   TEST(almost_equal(PI_REAL64,           3.141592653589793_REAL64))
   TEST(almost_equal(rad_from_deg(1.0_REAL64), 0.017453292519943295_REAL64))
   TEST(almost_equal(deg_from_rad(1.0_REAL64), 57.29577951308232_REAL64))

   write(OUTPUT_UNIT, *) "SUCCESS: ", __FILE__
   stop
end program constant_lib_test
