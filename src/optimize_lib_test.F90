#include "utils.h"
program main
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, intrinsic:: iso_fortran_env, only: REAL64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: optimize_lib, only: nnls

   implicit none

   TEST(all(almost_equal(nnls(real(reshape([73, 87, 72, 80, 71, 74, 2, 89, 52, 46, 7, 71], shape=[4, 3]), kind=REAL64), real([49, 67, 68, 20], kind=REAL64)), [0.6495384364022547_REAL64, 0.0_REAL64, 0.0_REAL64])))
   TEST(all(almost_equal(nnls(real(reshape([1, 1, 0, 1], shape=[2, 2]), kind=REAL64), real([1, 0], kind=REAL64)), [1.0/2, 0.0])))

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program main
