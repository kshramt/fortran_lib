# include "utils.h"
program main
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, non_intrinsic:: math_lib
   use, non_intrinsic:: comparable_lib, only: almost_equal

   implicit none

   Integer, allocatable:: zs(:)

   allocate(zs(1:5))
   call convolution([1, 2, 3], [1, 2, 3, 4], zs)
   TEST(all(zs == [1, 4, 10, 16, 17]))

   TEST(almost_equal(linear_transform(0.1, 0.0, 1.0, 2.0, 3.0), 2.1))

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program main
