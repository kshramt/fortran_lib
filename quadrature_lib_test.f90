#include "fortran_lib.h"
program main
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit
   use, intrinsic:: iso_fortran_env, only: int64, real64
   USE_FORTRAN_LIB_H
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: quadrature_lib

   implicit none

   Real(kind=real64), parameter:: pi = 2*atan2(1d0, 0d0)
   Logical:: err



   TEST(almost_equal(romberg(my_sin, 0d0, pi), 2d0))
   TEST(almost_equal(romberg(my_sin, 0d0, pi, err=err), 2d0))
   TEST(.not.err)
   TEST(almost_equal(romberg(inv_x, 1d0/2, 2d0), log(4d0)))
   TEST(almost_equal(romberg(inv_x, 1d0/2, 2d0, err=err), log(4d0)))
   TEST(.not.err)

   write(output_unit, *) 'SUCCESS: ', __FILE__

   stop

contains

   pure function my_sin(x) result(ret)
      Real(kind=real64), intent(in):: x
      Real(kind=kind(x)):: ret

      ret = sin(x)
   end function my_sin

   pure function inv_x(x) result(ret)
      Real(kind=real64), intent(in):: x
      Real(kind=kind(x)):: ret

      ret = 1/x
   end function inv_x

end program main
