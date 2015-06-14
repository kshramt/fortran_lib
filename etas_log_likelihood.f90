#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit
   use, intrinsic:: iso_fortran_env, only: int64, real64
   use, non_intrinsic:: ad_lib, only: Dual64_2_5, real, jaco, hess
   use, non_intrinsic:: etas_lib, only: log_likelihood_etas

   implicit none

   Integer(kind=int64), parameter:: n_params = 5
   type(Dual64_2_5):: log_likelihood
   type(Dual64_2_5):: d_c, d_p, d_alpha, d_K, d_mu
   Real(kind=real64):: jacobian(n_params), hessian(n_params, n_params)
   Real(kind=real64), allocatable:: ts(:), ms(:)
   Real(kind=real64):: c, p, alpha, K, mu
   Real(kind=real64):: normalize_interval, m_for_K
   Real(kind=real64):: t_begin, t_end, t_len
   Integer(kind=int64):: i, j, n
   Integer:: ios

   read(input_unit, *) normalize_interval
   read(input_unit, *) m_for_K
   read(input_unit, *) t_begin
   read(input_unit, *) t_end
   ASSERT(t_begin <= t_end)
   read(input_unit, *) n
   allocate(ts(n))
   allocate(ms(n))
   do i = 1, n
      read(input_unit, *) ts(i), ms(i)
   end do
   ms(:) = ms - m_for_K
   ASSERT(t_begin <= ts(1))
   ASSERT(ts(n) <= t_end)
   ts(:) = ts - t_begin
   t_len = t_end - t_begin

   do
      read(input_unit, *, iostat=ios) c, p, alpha, K, mu
      if(ios /= 0) exit
      d_c = Dual64_2_5(c, [1, 0, 0, 0, 0])
      d_p = Dual64_2_5(p, [0, 1, 0, 0, 0])
      d_alpha = Dual64_2_5(alpha, [0, 0, 1, 0, 0])
      d_K = Dual64_2_5(K, [0, 0, 0, 1, 0])
      d_mu = Dual64_2_5(mu, [0, 0, 0, 0, 1])
      log_likelihood = log_likelihood_etas(t_len, normalize_interval, d_c, d_p, d_alpha, d_K, d_mu, ts, ms)
      jacobian = jaco(log_likelihood)
      hessian = hess(log_likelihood)
      write(output_unit, *) real(log_likelihood)
      write(output_unit, *) (jacobian(i), i = 1, n_params)
      do i = 1, n_params
         write(output_unit, *) (hessian(i, j), j = 1, n_params)
      end do
   end do

   stop
end program main
