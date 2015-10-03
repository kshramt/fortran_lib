#include "fortran_lib.h"
program main
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit
   use, intrinsic:: iso_fortran_env, only: int32, int64, real64
   USE_FORTRAN_LIB_H
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: quadpack_lib

   implicit none

   Real(kind=real64), parameter:: pi = 2*atan2(1d0, 0d0)
   Integer(kind=int32):: err, n_eval
   Real(kind=real64):: ret, abs_err


   call qags(my_sin, 0d0, pi, ret, n_eval=n_eval, err=err, abs_err=abs_err)
   TEST(almost_equal(ret, 2d0, atol=abs_err))
   TEST(err == 0)

   call qags(inv_x, 1d0/2, 2d0, ret, n_eval=n_eval, err=err, abs_err=abs_err)
   TEST(almost_equal(ret, log(4d0), atol=abs_err))
   TEST(err == 0)

   ! TEST(almost_equal(qags(inv_x_args, 1d0/2, 2d0, [3d0]), 3*log(4d0), rtol=2*epsilon(0d0)))
   ! TEST(almost_equal(qags(inv_x_args, 1d0/2, 2d0, [3d0], err=err, n_eval=n_eval), 3*log(4d0), rtol=2*epsilon(0d0)))
   ! TEST(.not.err)


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

   pure function inv_x_args(x, args) result(ret)
      Real(kind=real64), intent(in):: x
      Real(kind=real64), intent(in):: args(:) ! args(1) does not work
      Real(kind=kind(x)):: ret

      ret = args(1)/x
   end function inv_x_args

end program main
