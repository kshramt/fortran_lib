#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, intrinsic:: iso_fortran_env, only: REAL64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: optimize_lib, only: nnls
   use, non_intrinsic:: optimize_lib, only: init, update, LineSearchStateRealDim0KindREAL32

   implicit none

   TEST(all(almost_equal(nnls(real(reshape([73, 87, 72, 80, 71, 74, 2, 89, 52, 46, 7, 71], shape=[4, 3]), kind=REAL64), real([49, 67, 68, 20], kind=REAL64)), [0.6495384364022547_REAL64, 0.0_REAL64, 0.0_REAL64])))
   TEST(all(almost_equal(nnls(real(reshape([1, 1, 0, 1], shape=[2, 2]), kind=REAL64), real([1, 0], kind=REAL64)), [1.0/2, 0.0])))

   TEST(test_line_search(-3.0, 2.5, 10.0))
   TEST(test_line_search(50.0, 0.15, 10.0))

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop

contains

   function test_line_search(x0, dx, x_theoretical) result(ret)
      Logical:: ret
      Real, intent(in):: x0, dx, x_theoretical
      Real:: f, f0, fdx, x, xl, xr, x_best, f_best, xtol
      Logical:: converge_x
      type(LineSearchStateRealDim0KindREAL32):: s
      Integer:: iter

      ret = .false.
      xtol = 1e-2*dx
      f0 = test_line_search_f(x0, x_theoretical)
      fdx = test_line_search_f(x0 + dx, x_theoretical)
      if(fdx < f0)then
         x_best = 0
         f_best = f0
      else
         x_best = dx
         f_best = fdx
      end if
      call init(s, f0, fdx)
      iter = 0
      do
         iter = iter + 1
         x = x0 + s%x*dx
         xl = x0 + s%xl*dx
         xr = x0 + s%xr*dx
         f = test_line_search_f(x, x_theoretical)
         write(output_unit, *) xl, xr, x, test_line_search_f(xl, x_theoretical), test_line_search_f(xr, x_theoretical), f
         call update(s, f)
         converge_x = almost_equal(x, x_best, absolute=xtol)
         if(f < f_best)then
            x_best = x
            f_best = f
         end if
         if(converge_x) exit
      end do
      PRINT_VARIABLE(iter)
      PRINT_VARIABLE(x_best)
      ret = almost_equal(x, x_best, xtol)
   end function test_line_search


   function test_line_search_f(x, x_theoretical) result(ret)
      Real, intent(in):: x, x_theoretical
      Real(kind=kind(x)):: ret

      ret = -1/(1 + (x - x_theoretical)**2)
   end function test_line_search_f
end program
