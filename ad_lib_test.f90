#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT, real64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: ad_lib

   implicit none

   type(Dual64_2_2):: x, y, z, xs(3213)
   Real(kind=real64), parameter:: a = 6, b = 2, zero = 0, one = 1
   Real(kind=real64):: h(2, 2), j(2)
   Integer:: i, nxs

   x%f = a
   x%g(1) = 1
   y%f = b
   y%g(2) = 1

   TEST(almost_equal(epsilon(x), epsilon(a)))
   TEST(almost_equal(tiny(x), tiny(a)))
   TEST(almost_equal(huge(x), huge(a)))

   z = dot_product([x, y, y], [x, x, y])
   TEST(real(z) == a*a + b*a + b*b)
   TEST(all(jaco(z) == jaco(x*x + y*x + y*y)))
   TEST(all(hess(z) == hess(x*x + y*x + y*y)))

   z = sum([x, y])
   TEST(real(z) == a + b)
   TEST(all(jaco(z) == [1, 1]))
   TEST(all(hess(z) == 0))
   nxs = size(xs)
   do i = 1, nxs
      xs(i) = exp(x*y + log(y))
   end do
   z = sum(xs)
   TEST(almost_equal(real(z), nxs*real(xs(1)), relative=4*epsilon(z)))
   TEST(all(almost_equal(jaco(z), nxs*jaco(xs(1)), relative=4*epsilon(z))))
   TEST(all(almost_equal(hess(z), nxs*hess(xs(1)), relative=4*epsilon(z))))

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

   z = exp(x)
   TEST(almost_equal(real(z), exp(a)))
   j = jaco(z)
   TEST(almost_equal(j(1), exp(a)))
   TEST(j(2) == 0)
   h = hess(z)
   TEST(almost_equal(h(1, 1), exp(a)))
   TEST(h(1, 2) == 0)
   TEST(h(2, 1) == 0)
   TEST(h(2, 2) == 0)

   z = exp(y)
   TEST(almost_equal(real(z), exp(b)))
   j = jaco(z)
   TEST(j(1) == 0)
   TEST(almost_equal(j(2), exp(b)))
   h = hess(z)
   TEST(h(1, 1) == 0)
   TEST(h(1, 2) == 0)
   TEST(h(2, 1) == 0)
   TEST(almost_equal(h(2, 2), exp(b)))

   z = log(x)
   TEST(almost_equal(real(z), log(a)))
   j = jaco(z)
   TEST(almost_equal(j(1), 1/a))
   TEST(j(2) == 0)
   h = hess(z)
   TEST(almost_equal(h(1, 1), -1/a**2))
   TEST(h(1, 2) == 0)
   TEST(h(2, 1) == 0)
   TEST(h(2, 2) == 0)

   z = log(y)
   TEST(almost_equal(real(z), log(b)))
   j = jaco(z)
   TEST(j(1) == 0)
   TEST(almost_equal(j(2), 1/b))
   h = hess(z)
   TEST(h(1, 1) == 0)
   TEST(h(1, 2) == 0)
   TEST(h(2, 1) == 0)
   TEST(almost_equal(h(2, 2), -1/b**2))

   z = exp(log(x + y))
   TEST(almost_equal(real(z), a + b))
   TEST(all(almost_equal(jaco(z), one)))
   TEST(all(hess(z) == 0))

   z = log(exp(x + y))
   TEST(almost_equal(real(z), a + b))
   TEST(all(almost_equal(jaco(z), one)))
   TEST(all(hess(z) == 0))

   z = log(x*x/y + exp(y))
   TEST(almost_equal(real(z), log(a*a/b + exp(b))))
   j = jaco(z)
   TEST(almost_equal(j(1), 2*a/(b*(a**2/b + exp(b)))))
   TEST(almost_equal(j(2), (-a**2/b**2 + exp(b))/(a**2/b + exp(b))))
   h = hess(z)
   TEST(almost_equal(h(1, 1), (-2*a**2 + 2*b*exp(b))/(a**2 + b*exp(b))**2))
   TEST(almost_equal(h(1, 2), -(2*a*(b + 1)*exp(b))/(a**2 + b*exp(b))**2))
   TEST(almost_equal(h(2, 1), -(2*a*(b + 1)*exp(b))/(a**2 + b*exp(b))**2))
   TEST(almost_equal(h(2, 2), (2*a**2*(a**2 + b*exp(b)) + b**3*(a**2 + b*exp(b))*exp(b) - (a**2 - b**2*exp(b))**2)/(b**2*(a**2 + b*exp(b))**2)))

   TEST(x == a)
   TEST(x <= a)
   TEST(x >= a)
   TEST(x < 100)
   TEST(x > -100)

   TEST(a > b)
   TEST(b < a)
   TEST(a <= a)
   TEST(a >= a)
   TEST(a == a)

   ! scalar to dual operations

   ! +
   z = x + 3
   TEST(real(z) == a + 3)
   TEST(all(jaco(z) == [1, 0]))
   TEST(all(hess(z) == 0))
   z = y + 3
   TEST(real(z) == b + 3)
   TEST(all(jaco(z) == [0, 1]))
   TEST(all(hess(z) == 0))

   z = 3 + x
   TEST(real(z) == a + 3)
   TEST(all(jaco(z) == [1, 0]))
   TEST(all(hess(z) == 0))
   z = 3 + y
   TEST(real(z) == b + 3)
   TEST(all(jaco(z) == [0, 1]))
   TEST(all(hess(z) == 0))

   ! +
   z = x - 3
   TEST(real(z) == a - 3)
   TEST(all(jaco(z) == [1, 0]))
   TEST(all(hess(z) == 0))
   z = y - 3
   TEST(real(z) == b - 3)
   TEST(all(jaco(z) == [0, 1]))
   TEST(all(hess(z) == 0))

   z = 3 - x
   TEST(real(z) == 3 - a)
   TEST(all(jaco(z) == [-1, 0]))
   TEST(all(hess(z) == 0))
   z = 3 - y
   TEST(real(z) == 3 - b)
   TEST(all(jaco(z) == [0, -1]))
   TEST(all(hess(z) == 0))

   ! *
   z = x*3
   TEST(real(z) == a*3)
   TEST(all(jaco(z) == [3, 0]))
   TEST(all(hess(z) == 0))
   z = y*3
   TEST(real(z) == b*3)
   TEST(all(jaco(z) == [0, 3]))
   TEST(all(hess(z) == 0))

   z = 3*x
   TEST(real(z) == a*3)
   TEST(all(jaco(z) == [3, 0]))
   TEST(all(hess(z) == 0))
   z = 3*y
   TEST(real(z) == b*3)
   TEST(all(jaco(z) == [0, 3]))
   TEST(all(hess(z) == 0))

   ! /
   z = x/3
   TEST(real(z) == a/3)
   j = jaco(z)
   TEST(almost_equal(j(1), one/3))
   TEST(j(2) == 0)
   TEST(all(hess(z) == 0))
   z = y/3
   TEST(real(z) == b/3)
   j = jaco(z)
   TEST(j(1) == 0)
   TEST(almost_equal(j(2), one/3))
   TEST(all(hess(z) == 0))

   z = 3/x
   TEST(real(z) == 3/a)
   j = jaco(z)
   TEST(almost_equal(j(1), -3/a**2))
   TEST(j(2) == 0)
   h = hess(z)
   TEST(almost_equal(h(1, 1), 6/a**3))
   TEST(h(1, 2) == 0)
   TEST(h(2, 1) == 0)
   TEST(h(2, 2) == 0)
   z = 3/y
   TEST(real(z) == 3/b)
   j = jaco(z)
   TEST(j(1) == 0)
   TEST(almost_equal(j(2), -3/b**2))
   h = hess(z)
   TEST(h(1, 1) == 0)
   TEST(h(1, 2) == 0)
   TEST(h(2, 1) == 0)
   TEST(almost_equal(h(2, 2), 6/b**3))

   ! **
   z = x**3
   TEST(real(z) == a**3)
   j = jaco(z)
   TEST(j(1) == 3*a**2)
   TEST(j(2) == 0)
   h = hess(z)
   TEST(almost_equal(h(1, 1), 6*a))
   TEST(h(1, 2) == 0)
   TEST(h(2, 1) == 0)
   TEST(h(2, 2) == 0)
   z = y**3
   TEST(real(z) == b**3)
   j = jaco(z)
   TEST(j(1) == 0)
   TEST(j(2) == 3*b**2)
   h = hess(z)
   TEST(h(1, 1) == 0)
   TEST(h(1, 2) == 0)
   TEST(h(2, 1) == 0)
   TEST(almost_equal(h(2, 2), 6*b))

   z = 3**x
   TEST(real(z) == 3**a)
   j = jaco(z)
   TEST(almost_equal(j(1), log(3*one)*3**a))
   TEST(j(2) == 0)
   h = hess(z)
   TEST(almost_equal(h(1, 1), log(3*one)**2*3**a))
   TEST(h(1, 2) == 0)
   TEST(h(2, 1) == 0)
   TEST(h(2, 2) == 0)
   z = 3**y
   TEST(real(z) == 3**b)
   j = jaco(z)
   TEST(j(1) == 0)
   TEST(almost_equal(j(2), log(3*one)*3**b))
   h = hess(z)
   TEST(h(1, 1) == 0)
   TEST(h(1, 2) == 0)
   TEST(h(2, 1) == 0)
   TEST(almost_equal(h(2, 2), log(3*one)**2*3**b))

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program main
