#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit, int64, real64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: ad_lib, only: Dual64_2_5
   use, non_intrinsic:: ad_lib, only: real, grad
   use, non_intrinsic:: etas_lib, only: log_likelihood_etas, index_ge, index_le, index_lt

   implicit none

   Integer(kind=int64), parameter:: one = 1
   Real(kind=real64), parameter:: ts(13) = [ &
      0d0, &
      0.0689465277779985d0, &
      0.171257407408622d0, &
      0.233481250002428d0, &
      0.328517476852845d0, &
      0.426012731481481d0, &
      0.529502777780096d0, &
      0.630255208335541d0, &
      0.727389699074405d0, &
      0.854635995372578d0, &
      0.996636689815808d0, &
      1.18308449074074d0, &
      1.39746527777778d0 &
      ]
   Real(kind=real64), parameter:: dms(13) = [ &
      0d0, &
      -4.1d0, &
      -4.5d0, &
      -5.4d0, &
      -6.1d0, &
      -5.7d0, &
      -5.8d0, &
      -7.4d0, &
      -6d0, &
      -2.5d0, &
      -5.2d0, &
      -6.9d0, &
      -6.9d0 &
      ]
   Real(kind=kind(ts)):: t_end, normalize_interval, mu, K, c, alpha, p
   type(Dual64_2_5):: d_c, d_p, d_alpha, d_K, d_mu

   t_end = 1.5d0
   normalize_interval = 1
   c = 1d0/24
   alpha = 1
   mu = 100
   d_mu = Dual64_2_5(mu, [1, 0, 0, 0, 0])
   d_c = Dual64_2_5(c, [0, 0, 1, 0, 0])
   d_alpha = Dual64_2_5(alpha, [0, 0, 0, 1, 0])

   p = 2d-1
   K = 104
   TEST(almost_equal(log_likelihood_etas(0d0, t_end, normalize_interval, mu, K, c, alpha, p, ts, dms, one, dms > -huge(0d0)), -238.82597918687705d0))
   d_p = Dual64_2_5(p, [0, 0, 0, 0, 1])
   d_k = Dual64_2_5(K, [0, 1, 0, 0, 0])
   TEST(almost_equal(real(log_likelihood_etas(0d0, t_end, normalize_interval, d_mu, d_K, d_c, d_alpha, d_p, ts, dms, one, dms > -huge(0d0))), -238.82597918687705d0))

   p = 6d-1
   K = 120
   TEST(almost_equal(log_likelihood_etas(0d0, t_end, normalize_interval, mu, K, c, alpha, p, ts, dms, one, dms > -huge(0d0)), -243.80278501664003d0))
   d_p = Dual64_2_5(p, [0, 0, 0, 0, 1])
   d_k = Dual64_2_5(K, [0, 1, 0, 0, 0])
   TEST(almost_equal(real(log_likelihood_etas(0d0, t_end, normalize_interval, d_mu, d_K, d_c, d_alpha, d_p, ts, dms, one, dms > -huge(0d0))), -243.80278501664003d0))

   p = 1
   K = 120
   TEST(almost_equal(log_likelihood_etas(0d0, t_end, normalize_interval, mu, K, c, alpha, p, ts, dms, one, dms > -huge(0d0)), -232.04236722101803d0))
   d_p = Dual64_2_5(p, [0, 0, 0, 0, 1])
   d_k = Dual64_2_5(K, [0, 1, 0, 0, 0])
   TEST(almost_equal(real(log_likelihood_etas(0d0, t_end, normalize_interval, d_mu, d_K, d_c, d_alpha, d_p, ts, dms, one, dms > -huge(0d0))), -232.04236722101803d0))
   TEST(all(almost_equal(grad(log_likelihood_etas(0d0, t_end, normalize_interval, d_mu, d_K, d_c, d_alpha, d_p, ts, dms, one, dms > -huge(0d0))), [-1.4229686278967888d0, -1.2014840427587559d0, -66.823472324117404d0, 50.443481642939808d0,  38.410272133423234d0], rtol=4*epsilon(0d0))))


   ASSERT(index_ge(ts, 0d0 - 0.01, int(1, kind=int64), size64(ts)) == 1)
   ASSERT(index_ge(ts, 0d0, int(1, kind=int64), size64(ts)) == 1)
   ASSERT(index_ge(ts, 0.0689465277779985d0 - 0.01, int(1, kind=int64), size64(ts)) == 2)
   ASSERT(index_ge(ts, 0.0689465277779985d0, int(1, kind=int64), size64(ts)) == 2)
   ASSERT(index_ge(ts, 1.39746527777778d0 - 0.01, int(1, kind=int64), size64(ts)) == size64(ts))
   ASSERT(index_ge(ts, 1.39746527777778d0, int(1, kind=int64), size64(ts)) == size64(ts))
   ASSERT(index_ge(ts, 1.39746527777778d0 + 0.01, int(1, kind=int64), size64(ts)) == size64(ts) + 1)

   ASSERT(index_le(ts, 0d0 - 0.01, int(1, kind=int64), size64(ts)) == 0)
   ASSERT(index_le(ts, 0d0, int(1, kind=int64), size64(ts)) == 1)
   ASSERT(index_le(ts, 0.0689465277779985d0 - 0.01, int(1, kind=int64), size64(ts)) == 1)
   ASSERT(index_le(ts, 0.0689465277779985d0, int(1, kind=int64), size64(ts)) == 2)
   ASSERT(index_le(ts, 1.39746527777778d0 - 0.01, int(1, kind=int64), size64(ts)) == size64(ts) - 1)
   ASSERT(index_le(ts, 1.39746527777778d0, int(1, kind=int64), size64(ts)) == size64(ts))
   ASSERT(index_le(ts, 1.39746527777778d0 + 0.01, int(1, kind=int64), size64(ts)) == size64(ts))

   PRINT_VARIABLE(index_lt(ts, 0d0 - 0.01, int(1, kind=int64), size64(ts)))
   ASSERT(index_lt(ts, 0d0 - 0.01, int(1, kind=int64), size64(ts)) == 0)
   ASSERT(index_lt(ts, 0d0, int(1, kind=int64), size64(ts)) == 0)
   ASSERT(index_lt(ts, 0.0689465277779985d0 - 0.01, int(1, kind=int64), size64(ts)) == 1)
   ASSERT(index_lt(ts, 0.0689465277779985d0, int(1, kind=int64), size64(ts)) == 1)
   ASSERT(index_lt(ts, 1.39746527777778d0 - 0.01, int(1, kind=int64), size64(ts)) == size64(ts) - 1)
   ASSERT(index_lt(ts, 1.39746527777778d0, int(1, kind=int64), size64(ts)) == size64(ts) - 1)
   ASSERT(index_lt(ts, 1.39746527777778d0 + 0.01, int(1, kind=int64), size64(ts)) == size64(ts))

   stop
end program main
