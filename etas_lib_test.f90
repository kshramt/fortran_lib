#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit, int64, real64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: ad_lib, only: Dual64_2_5
   use, non_intrinsic:: ad_lib, only: real, jaco
   use, non_intrinsic:: etas_lib, only: log_likelihood_etas

   implicit none

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
   Real(kind=real64), parameter:: ms(13) = [ &
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
   Real(kind=kind(ts)):: t_end, normalize_interval, c, p, alpha, K, mu
   type(Dual64_2_5):: d_c, d_p, d_alpha, d_K, d_mu

   t_end = 1.5d0
   normalize_interval = 1
   c = 1d0/24
   alpha = 1
   mu = 100
   d_c = Dual64_2_5(c, [1, 0, 0, 0, 0])
   d_alpha = Dual64_2_5(alpha, [0, 0, 1, 0, 0])
   d_mu = Dual64_2_5(mu, [0, 0, 0, 0, 1])

   p = 2d-1
   K = 104
   TEST(almost_equal(log_likelihood_etas(t_end, normalize_interval, c, p, alpha, K, mu, ts, ms), -238.82597918687705d0))
   d_p = Dual64_2_5(p, [0, 1, 0, 0, 0])
   d_k = Dual64_2_5(K, [0, 0, 0, 1, 0])
   TEST(almost_equal(real(log_likelihood_etas(t_end, normalize_interval, d_c, d_p, d_alpha, d_K, d_mu, ts, ms)), -238.82597918687705d0))

   p = 6d-1
   K = 120
   TEST(almost_equal(log_likelihood_etas(t_end, normalize_interval, c, p, alpha, K, mu, ts, ms), -243.80278501664003d0))
   d_p = Dual64_2_5(p, [0, 1, 0, 0, 0])
   d_k = Dual64_2_5(K, [0, 0, 0, 1, 0])
   TEST(almost_equal(real(log_likelihood_etas(t_end, normalize_interval, d_c, d_p, d_alpha, d_K, d_mu, ts, ms)), -243.80278501664003d0))

   p = 1
   K = 120
   PRINT_VARIABLE(log_likelihood_etas(t_end, normalize_interval, c, p, alpha, K, mu, ts, ms))
   TEST(almost_equal(log_likelihood_etas(t_end, normalize_interval, c, p, alpha, K, mu, ts, ms), -232.04236722101803d0))
   d_p = Dual64_2_5(p, [0, 1, 0, 0, 0])
   d_k = Dual64_2_5(K, [0, 0, 0, 1, 0])
   TEST(almost_equal(real(log_likelihood_etas(t_end, normalize_interval, d_c, d_p, d_alpha, d_K, d_mu, ts, ms)), -232.04236722101803d0))
   TEST(all(almost_equal(jaco(log_likelihood_etas(t_end, normalize_interval, d_c, d_p, d_alpha, d_K, d_mu, ts, ms)), [-66.823472324117404d0, 38.410272133423234d0, 50.443481642939808d0, -1.2014840427587559d0, -1.4229686278967888d0])))

   stop
end program main
