#include "fortran_lib.h"
program main
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit
   use, intrinsic:: iso_fortran_env, only: int32, int64, real64
   USE_FORTRAN_LIB_H
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: ad_lib
   use, non_intrinsic:: quadpack_lib, only: qags

   implicit none

   Real(kind=real64), parameter:: pi = 2*atan2(1d0, 0d0)
   Integer(kind=int32):: err, n_eval
   Real(kind=real64):: ret, abs_err
   type(Dual64_2_2):: dual_ret, dual_abs_err

   call qags(my_sin, 0d0, pi, ret, n_eval=n_eval, err=err, abs_err=abs_err)
   TEST(err == 0)
   TEST(almost_equal(ret, 2d0, atol=abs_err))

   call qags(dual_3sin, 0d0, pi, dual_ret, n_eval=n_eval, err=err, abs_err=dual_abs_err)
   TEST(err == 0)
   TEST(almost_equal(real(dual_ret), 6d0, atol=real(dual_abs_err)))
   TEST(all(almost_equal(grad(dual_ret), 2d0, atol=grad(dual_abs_err))))

   call qags(inv_x, 1d0/2, 2d0, ret, n_eval=n_eval, err=err, abs_err=abs_err)
   TEST(err == 0)
   TEST(almost_equal(ret, log(4d0), atol=abs_err))

   call qags(inv_x2, 1d0/1024, 1024d0, ret, n_eval=n_eval, err=err, abs_err=abs_err)
   TEST(err == 0)
   TEST(almost_equal(ret, (1048575d0/1024) - (10*sqrt(10d0)*atan2(476625*sqrt(5d0/2), 23296d0)), atol=abs_err))


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

   pure function inv_x2(x) result(ret)
      Real(kind=real64), intent(in):: x
      Real(kind=kind(x)):: ret

      ret = (1 - 1/(x**2 + 1d-3))
   end function inv_x2

   pure function inv_x_args(x, args) result(ret)
      Real(kind=real64), intent(in):: x
      Real(kind=real64), intent(in):: args(:) ! args(1) does not work
      Real(kind=kind(x)):: ret

      ret = args(1)/x
   end function inv_x_args

   pure function dual_3sin(x) result(ret)
      Real(kind=real64), intent(in):: x
      type(Dual64_2_2):: ret

      ret = sin(x)*Dual64_2_2(3, 1)
   end function dual_3sin
end program main
