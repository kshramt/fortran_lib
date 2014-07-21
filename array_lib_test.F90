#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, intrinsic:: iso_fortran_env, only: INT64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: array_lib, only: iota, l2_norm
   
   implicit none

   Integer:: i

   TEST(almost_equal(l2_norm([1.0, 2.0]), 5.0))

   TEST(all(iota(0) == [(i, i = 1, 0)]))
   TEST(all(iota(1) == [1]))
   TEST(all(iota(2) == [1, 2]))
   TEST(all(iota(3) == [1, 2, 3]))

   TEST(all(iota(-3, -4) == [(i, i = 1, 0)]))
   TEST(all(iota(-3, -3) == [-3]))
   TEST(all(iota(-3, -2) == [-3, -2]))
   TEST(all(iota(-3, -1) == [-3, -2, -1]))

   TEST(all(iota(2, 3, -3) == [(i, i = 1, 0)]))
   TEST(all(iota(2, 2, -3) == [2]))
   TEST(all(iota(2, 1, -3) == [2]))
   TEST(all(iota(2, 0, -3) == [2]))
   TEST(all(iota(2, -1, -3) == [2, -1]))
   TEST(all(iota(2, -2, -3) == [2, -1]))
   TEST(all(iota(2, -3, -3) == [2, -1]))
   TEST(all(iota(2, -4, -3) == [2, -1, -4]))

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__
   
   stop
end program main
