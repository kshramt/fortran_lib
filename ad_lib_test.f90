#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT, real64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: ad_lib

   implicit none

   type(Dual64_2_2):: x, y, z, xs(3213)
   Real(kind=real64), parameter:: a = 6, b = 2, zero = 0, one = 1, two = 2, three = 3
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
   TEST(almost_equal(real(z), a*a + b*a + b*b))
   TEST(all(almost_equal(jaco(z), jaco(x*x + y*x + y*y))))
   TEST(all(almost_equal(hess(z), hess(x*x + y*x + y*y))))

   z = dot_product([x, y, y], [a, a, b])
   TEST(almost_equal(real(z), a*a + b*a + b*b))
   TEST(all(almost_equal(jaco(z), jaco(x*a + y*a + y*b))))
   TEST(all(almost_equal(hess(z), hess(x*a + y*a + y*b))))

   z = dot_product([a, b, b], [x, x, y])
   TEST(almost_equal(real(z), a*a + b*a + b*b))
   TEST(all(almost_equal(jaco(z), jaco(a*x + b*x + b*y))))
   TEST(all(almost_equal(hess(z), hess(a*x + b*x + b*y))))

   z = sum([x, y])
   TEST(almost_equal(real(z), a + b))
   TEST(all(almost_equal(jaco(z), [one, one])))
   TEST(all(almost_equal(hess(z), zero)))
   nxs = size(xs)
   do i = 1, nxs
      xs(i) = exp(x*y + log(y))
   end do
   z = sum(xs)
   TEST(almost_equal(real(z), nxs*real(xs(1)), relative=4*epsilon(z)))
   TEST(all(almost_equal(jaco(z), nxs*jaco(xs(1)), relative=4*epsilon(z))))
   TEST(all(almost_equal(hess(z), nxs*hess(xs(1)), relative=4*epsilon(z))))

   z = x + y
   TEST(almost_equal(real(z), a + b))
   TEST(all(almost_equal(jaco(z), [one, one])))
   TEST(all(almost_equal(hess(z), zero)))

   z = x + x
   TEST(almost_equal(real(z), a + a))
   TEST(all(almost_equal(jaco(z), [two, zero])))
   TEST(all(almost_equal(hess(z), zero)))

   z = x - y
   TEST(almost_equal(real(z), a - b))
   TEST(all(almost_equal(jaco(z), [one, -one])))
   TEST(all(almost_equal(hess(z), zero)))

   z = x - x
   TEST(almost_equal(real(z), zero))
   TEST(all(almost_equal(jaco(z), zero)))
   TEST(all(almost_equal(hess(z), zero)))

   z = x*y
   TEST(almost_equal(real(z), a*b))
   TEST(all(almost_equal(jaco(z), [b, a])))
   h = hess(z)
   TEST(almost_equal(h(1, 1), zero))
   TEST(almost_equal(h(1, 2), one))
   TEST(almost_equal(h(2, 1), one))
   TEST(almost_equal(h(2, 2), zero))

   z = x*x
   TEST(almost_equal(real(z), a*a))
   TEST(all(almost_equal(jaco(z), [2*a, zero])))
   h = hess(z)
   TEST(almost_equal(h(1, 1), two))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 1), zero))
   TEST(almost_equal(h(2, 2), zero))

   z = x/y
   TEST(almost_equal(real(z), a/b))
   TEST(all(almost_equal(jaco(z), [1/b, -a/b**2])))
   h = hess(z)
   TEST(almost_equal(h(1, 1), zero))
   TEST(almost_equal(h(1, 2), -1/b**2))
   TEST(almost_equal(h(2, 1), -1/b**2))
   TEST(almost_equal(h(2, 2), 2*a/b**3))

   z = x/x
   TEST(almost_equal(real(z), one))
   TEST(all(almost_equal(jaco(z), zero)))
   TEST(all(almost_equal(hess(z), zero)))

   z = x**y
   TEST(almost_equal(real(z), a**b))
   TEST(all(almost_equal(jaco(z), [b*a**(b - 1), log(a)*a**b])))
   h = hess(z)
   TEST(almost_equal(h(1, 1), b*(b - 1)*a**(b - 2)))
   TEST(almost_equal(h(1, 2), a**(b - 1) + b*log(a)*a**(b - 1)))
   TEST(almost_equal(h(2, 1), a**(b - 1) + b*log(a)*a**(b - 1)))
   TEST(almost_equal(h(2, 2), log(a)**2*a**b))

   z = x**x
   TEST(almost_equal(real(z), a**a))
   j = jaco(z)
   TEST(almost_equal(j(1), (log(a) + 1)*a**a))
   TEST(almost_equal(j(2), zero))
   h = hess(z)
   TEST(almost_equal(h(1, 1), a**(a - 1) + (log(a) + 1)**2*a**a))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 2), zero))
   TEST(almost_equal(h(2, 2), zero))

   z = exp(x)
   TEST(almost_equal(real(z), exp(a)))
   j = jaco(z)
   TEST(almost_equal(j(1), exp(a)))
   TEST(almost_equal(j(2), zero))
   h = hess(z)
   TEST(almost_equal(h(1, 1), exp(a)))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 1), zero))
   TEST(almost_equal(h(2, 2), zero))

   z = exp(y)
   TEST(almost_equal(real(z), exp(b)))
   j = jaco(z)
   TEST(almost_equal(j(1), zero))
   TEST(almost_equal(j(2), exp(b)))
   h = hess(z)
   TEST(almost_equal(h(1, 1), zero))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 1), zero))
   TEST(almost_equal(h(2, 2), exp(b)))

   z = log(x)
   TEST(almost_equal(real(z), log(a)))
   j = jaco(z)
   TEST(almost_equal(j(1), 1/a))
   TEST(almost_equal(j(2), zero))
   h = hess(z)
   TEST(almost_equal(h(1, 1), -1/a**2))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 1), zero))
   TEST(almost_equal(h(2, 2), zero))

   z = log(y)
   TEST(almost_equal(real(z), log(b)))
   j = jaco(z)
   TEST(almost_equal(j(1), zero))
   TEST(almost_equal(j(2), 1/b))
   h = hess(z)
   TEST(almost_equal(h(1, 1), zero))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 1), zero))
   TEST(almost_equal(h(2, 2), -1/b**2))

   z = exp(log(x + y))
   TEST(almost_equal(real(z), a + b))
   TEST(all(almost_equal(jaco(z), one)))
   TEST(all(almost_equal(hess(z), zero)))

   z = log(exp(x + y))
   TEST(almost_equal(real(z), a + b))
   TEST(all(almost_equal(jaco(z), one)))
   TEST(all(almost_equal(hess(z), zero)))

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
   TEST(almost_equal(real(z), a + 3))
   TEST(all(almost_equal(jaco(z), [one, zero])))
   TEST(all(almost_equal(hess(z), zero)))
   z = y + 3
   TEST(almost_equal(real(z), b + 3))
   TEST(all(almost_equal(jaco(z), [zero, one])))
   TEST(all(almost_equal(hess(z), zero)))

   z = 3 + x
   TEST(almost_equal(real(z), a + 3))
   TEST(all(almost_equal(jaco(z), [one, zero])))
   TEST(all(almost_equal(hess(z), zero)))
   z = 3 + y
   TEST(almost_equal(real(z), b + 3))
   TEST(all(almost_equal(jaco(z), [zero, one])))
   TEST(all(almost_equal(hess(z), zero)))

   ! +
   z = x - 3
   TEST(almost_equal(real(z), a - 3))
   TEST(all(almost_equal(jaco(z), [one, zero])))
   TEST(all(almost_equal(hess(z), zero)))
   z = y - 3
   TEST(almost_equal(real(z), b - 3))
   TEST(all(almost_equal(jaco(z), [zero, one])))
   TEST(all(almost_equal(hess(z), zero)))

   z = 3 - x
   TEST(almost_equal(real(z), 3 - a))
   TEST(all(almost_equal(jaco(z), [-one, zero])))
   TEST(all(almost_equal(hess(z), zero)))
   z = 3 - y
   TEST(almost_equal(real(z), 3 - b))
   TEST(all(almost_equal(jaco(z), [zero, -one])))
   TEST(all(almost_equal(hess(z), zero)))

   ! *
   z = x*3
   TEST(almost_equal(real(z), a*3))
   TEST(all(almost_equal(jaco(z), [three, zero])))
   TEST(all(almost_equal(hess(z), zero)))
   z = y*3
   TEST(almost_equal(real(z), b*3))
   TEST(all(almost_equal(jaco(z), [zero, three])))
   TEST(all(almost_equal(hess(z), zero)))

   z = 3*x
   TEST(almost_equal(real(z), a*3))
   TEST(all(almost_equal(jaco(z), [three, zero])))
   TEST(all(almost_equal(hess(z), zero)))
   z = 3*y
   TEST(almost_equal(real(z), b*3))
   TEST(all(almost_equal(jaco(z), [zero, three])))
   TEST(all(almost_equal(hess(z), zero)))

   ! /
   z = x/3
   TEST(almost_equal(real(z), a/3))
   j = jaco(z)
   TEST(almost_equal(j(1), one/3))
   TEST(almost_equal(j(2), zero))
   TEST(all(almost_equal(hess(z), zero)))
   z = y/3
   TEST(almost_equal(real(z), b/3))
   j = jaco(z)
   TEST(almost_equal(j(1), zero))
   TEST(almost_equal(j(2), one/3))
   TEST(all(almost_equal(hess(z), zero)))

   z = 3/x
   TEST(almost_equal(real(z), 3/a))
   j = jaco(z)
   TEST(almost_equal(j(1), -3/a**2))
   TEST(almost_equal(j(2), zero))
   h = hess(z)
   TEST(almost_equal(h(1, 1), 6/a**3))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 1), zero))
   TEST(almost_equal(h(2, 2), zero))
   z = 3/y
   TEST(almost_equal(real(z), 3/b))
   j = jaco(z)
   TEST(almost_equal(j(1), zero))
   TEST(almost_equal(j(2), -3/b**2))
   h = hess(z)
   TEST(almost_equal(h(1, 1), zero))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 1), zero))
   TEST(almost_equal(h(2, 2), 6/b**3))

   ! **
   z = x**3
   TEST(almost_equal(real(z), a**3))
   j = jaco(z)
   TEST(almost_equal(j(1), 3*a**2))
   TEST(almost_equal(j(2), zero))
   h = hess(z)
   TEST(almost_equal(h(1, 1), 6*a))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 1), zero))
   TEST(almost_equal(h(2, 2), zero))
   z = y**3
   TEST(almost_equal(real(z), b**3))
   j = jaco(z)
   TEST(almost_equal(j(1), zero))
   TEST(almost_equal(j(2), 3*b**2))
   h = hess(z)
   TEST(almost_equal(h(1, 1), zero))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 1), zero))
   TEST(almost_equal(h(2, 2), 6*b))

   z = 3**x
   TEST(almost_equal(real(z), 3**a))
   j = jaco(z)
   TEST(almost_equal(j(1), log(three)*3**a))
   TEST(almost_equal(j(2), zero))
   h = hess(z)
   TEST(almost_equal(h(1, 1), log(three)**2*3**a))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 1), zero))
   TEST(almost_equal(h(2, 2), zero))
   z = 3**y
   TEST(almost_equal(real(z), 3**b))
   j = jaco(z)
   TEST(almost_equal(j(1), zero))
   TEST(almost_equal(j(2), log(three)*3**b))
   h = hess(z)
   TEST(almost_equal(h(1, 1), zero))
   TEST(almost_equal(h(1, 2), zero))
   TEST(almost_equal(h(2, 1), zero))
   TEST(almost_equal(h(2, 2), log(three)**2*3**b))

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program main
