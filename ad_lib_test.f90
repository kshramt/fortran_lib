#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT, real64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: ad_lib

   implicit none

   type(Dual64_2_2):: x, y, z
   Real(kind=real64), parameter:: a = 6, b = 2, zero = 0
   Real(kind=real64):: h(2, 2), j(2)

   x%f = a
   x%g(1) = 1
   y%f = b
   y%g(2) = 1

   z = x + y
   TEST(real(z) == a + b)
   TEST(all(jaco(z) == [1, 1]))
   TEST(all(hess(z) == 0))

   z = x + x
   TEST(real(z) == a + a)
   TEST(all(jaco(z) == [2, 0]))
   TEST(all(hess(z) == 0))

   z = x - y
   TEST(real(z) == a - b)
   TEST(all(jaco(z) == [1, -1]))
   TEST(all(hess(z) == 0))

   z = x - x
   TEST(real(z) == 0)
   TEST(all(jaco(z) == 0))
   TEST(all(hess(z) == 0))

   z = x*y
   TEST(real(z) == a*b)
   TEST(all(jaco(z) == [b, a]))
   h = hess(z)
   TEST(h(1, 1) == 0)
   TEST(h(1, 2) == 1)
   TEST(h(2, 1) == 1)
   TEST(h(2, 2) == 0)

   z = x*x
   TEST(real(z) == a*a)
   TEST(all(jaco(z) == [2*a, zero]))
   h = hess(z)
   TEST(h(1, 1) == 2)
   TEST(h(1, 2) == 0)
   TEST(h(2, 1) == 0)
   TEST(h(2, 2) == 0)

   z = x/y
   TEST(real(z) == a/b)
   TEST(all(almost_equal(jaco(z), [1/b, -a/b**2])))
   h = hess(z)
   TEST(h(1, 1) == 0)
   TEST(almost_equal(h(1, 2), -1/b**2))
   TEST(almost_equal(h(2, 1), -1/b**2))
   TEST(almost_equal(h(2, 2), 2*a/b**3))

   z = x/x
   TEST(real(z) == 1)
   TEST(all(jaco(z) == 0))
   TEST(all(hess(z) == 0))

   z = x**y
   TEST(real(z) == a**b)
   TEST(all(almost_equal(jaco(z), [b*a**(b - 1), log(a)*a**b])))
   h = hess(z)
   TEST(almost_equal(h(1, 1), b*(b - 1)*a**(b - 2)))
   TEST(almost_equal(h(1, 2), a**(b - 1) + b*log(a)*a**(b - 1)))
   TEST(almost_equal(h(2, 1), a**(b - 1) + b*log(a)*a**(b - 1)))
   TEST(almost_equal(h(2, 2), log(a)**2*a**b))

   z = x**x
   TEST(real(z) == a**a)
   j = jaco(z)
   TEST(almost_equal(j(1), (log(a) + 1)*a**a))
   TEST(j(2) == 0)
   h = hess(z)
   TEST(almost_equal(h(1, 1), a**(a - 1) + (log(a) + 1)**2*a**a))
   TEST(h(1, 2) == 0)
   TEST(h(2, 2) == 0)
   TEST(h(2, 2) == 0)

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program main
