#include "utils.h"
program main
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, intrinsic:: iso_fortran_env, only: REAL32, REAL64, REAL128
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: dual_lib, only: real, dual, diff, sin, cos, operator(+), operator(-), operator(*), operator(/)

   implicit none
   Integer:: i
   Real(kind=REAL32):: r

   do i = -10, 10
      r = real(i)

      ! +
      TEST(almost_equal(real(sin(dual(r, real(1))) + cos(dual(r, real(2)))), sin(r) + cos(r)))
      TEST(almost_equal(diff(sin(dual(r, real(1))) + cos(dual(r, real(2)))), cos(r) - 2*sin(r)))
      TEST(almost_equal(real(sin(dual(r, real(1))) + cos(r)), sin(r) + cos(r)))
      TEST(almost_equal(diff(sin(dual(r, real(1))) + cos(r)), cos(r)))

      ! -
      TEST(almost_equal(real(sin(dual(r, real(1))) - cos(dual(r, real(2)))), sin(r) - cos(r)))
      TEST(almost_equal(diff(sin(dual(r, real(1))) - cos(dual(r, real(2)))), cos(r) + 2*sin(r)))

      ! *
      TEST(almost_equal(real(sin(dual(r, real(1)))*cos(dual(r, real(2)))), sin(r)*cos(r)))
      TEST(almost_equal(diff(sin(dual(r, real(1)))*cos(dual(r, real(2)))), cos(r)*cos(r) - 2*sin(r)*sin(r)))

      ! /
      TEST(almost_equal(real(sin(dual(r, real(1)))/cos(dual(r, real(2)))), sin(r)/cos(r)))
      TEST(almost_equal(diff(sin(dual(r, real(1)))/cos(dual(r, real(2)))), (cos(r)*cos(r) + 2*sin(r)*sin(r))/(cos(r)**2)))

      ! comp
      TEST(almost_equal(real(sin(cos(dual(r, real(1))))), sin(cos(r))))
      TEST(almost_equal(diff(sin(cos(dual(r, real(1))))), -sin(r)*cos(cos(r))))

   end do

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program main
