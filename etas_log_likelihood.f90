#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit
   use, intrinsic:: iso_fortran_env, only: int64, real64
   use, non_intrinsic:: ad_lib, only: Dual64_2_5, real, jaco, hess
   use, non_intrinsic:: etas_lib, only: EtasInputs64, load, log_likelihood_etas

   implicit none

   Integer(kind=int64), parameter:: n_params = 5
   type(EtasInputs64):: ei
   type(Dual64_2_5):: log_likelihood
   type(Dual64_2_5):: d_c, d_p, d_alpha, d_K, d_mu
   Real(kind=real64):: hessian(n_params, n_params)
   Real(kind=real64):: c, p, alpha, K, mu
   Real(kind=real64):: t_begin, t_end, m_fit_min
   Integer(kind=int64):: i
   Integer:: ios

   call load(ei, input_unit)
   ei%ms(:) = ei%ms - ei%m_for_K

   do
      read(input_unit, *, iostat=ios) m_fit_min, t_begin, t_end, c, p, alpha, K, mu
      ASSERT(t_begin <= t_end)
      if(ios /= 0) exit
      d_c = Dual64_2_5(c, [1, 0, 0, 0, 0])
      d_p = Dual64_2_5(p, [0, 1, 0, 0, 0])
      d_alpha = Dual64_2_5(alpha, [0, 0, 1, 0, 0])
      d_K = Dual64_2_5(K, [0, 0, 0, 1, 0])
      d_mu = Dual64_2_5(mu, [0, 0, 0, 0, 1])
      log_likelihood = log_likelihood_etas(t_begin, t_end, ei%t_normalize_len, d_c, d_p, d_alpha, d_K, d_mu, ei%ts, ei%ms, ei%ms >= m_fit_min)
      hessian = hess(log_likelihood)
      write(output_unit, *) real(log_likelihood)
      write(output_unit, *) jaco(log_likelihood)
      do i = 1, n_params
         write(output_unit, *) hessian(i, :)
      end do
   end do

   stop
end program main
