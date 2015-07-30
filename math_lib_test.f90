# include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT, real64
   use, non_intrinsic:: math_lib
   use, non_intrinsic:: comparable_lib, only: almost_equal

   implicit none

   Integer, allocatable:: zs(:)
   Real(kind=real64):: d
   Real(kind=real64):: f, g(2), h(2, 2)
   Real(kind=real64):: f1, g1(2), h1(2, 2)
   Real(kind=real64):: f2, g2(2), h2(2, 2)
   Real(kind=real64):: f3, g3(2), h3(2, 2)


   TEST(mod1(0, 3) == 3)
   TEST(mod1(1, 3) == 1)
   TEST(mod1(2, 3) == 2)
   TEST(mod1(3, 3) == 3)
   TEST(mod1(4, 3) == 1)
   TEST(mod1(5, 3) == 2)
   TEST(mod1(6, 3) == 3)

   allocate(zs(1:5))
   call convolution([1, 2, 3], [1, 2, 3, 4], zs)
   TEST(all(zs == [1, 4, 10, 16, 17]))

   TEST(almost_equal(linear_transform(0.1, 0.0, 1.0, 2.0, 3.0), 2.1))
   call rosenbrock_fgh([1d0, 1d0], f, g, h)
   TEST(almost_equal(f, 0d0))
   TEST(all(almost_equal(g, [0d0, 0d0])))

   d = 1d-5
   call rosenbrock_fgh([2d0 - d, 1d0], f1, g1, h1)
   call rosenbrock_fgh([2d0, 1d0], f2, g2, h2)
   call rosenbrock_fgh([2d0 + d, 1d0], f3, g3, h3)
   TEST(almost_equal(g2(1), (f3 - f1)/(2*d), rtol=1d-4))
   TEST(all(almost_equal(h2(:, 1), (g3 - g1)/(2*d), rtol=1d-4)))

   call rosenbrock_fgh([2d0, 1d0 - d], f1, g1, h1)
   call rosenbrock_fgh([2d0, 1d0], f2, g2, h2)
   call rosenbrock_fgh([2d0, 1d0 + d], f3, g3, h3)
   TEST(almost_equal(g2(2), (f3 - f1)/(2*d), rtol=1d-4))
   TEST(all(almost_equal(h2(:, 2), (g3 - g1)/(2*d), rtol=1d-4)))

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program main
