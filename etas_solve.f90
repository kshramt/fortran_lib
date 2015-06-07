#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit, real64, int64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: optimize_lib, only: NewtonState64, init, update
   use, non_intrinsic:: ad_lib, only: Dual64_2_5, real, hess, jaco, operator(-), exp
   use, non_intrinsic:: etas_lib, only: log_likelihood_etas, omori_integrate, utsu_seki

   implicit none

   Integer(kind=int64), parameter:: n_params = 5
   Real(kind=real64), parameter:: lower_bounds(n_params) = [1d-8, -1d0, -1d0, 0d0, 1d-8]
   Real(kind=real64), parameter:: upper_bounds(n_params) = [huge(0d0), 30d0, 10d0, huge(0d0), huge(0d0)]
   Real(kind=real64), allocatable:: ts(:), ms(:)
   Real(kind=real64):: m_max
   type(NewtonState64):: s
   Real(kind=real64):: c_p_alpha_K_mu_best(n_params), c, p, alpha, K, mu
   Real(kind=real64):: t_begin, t_end, t_len, normalize_interval
   Real(kind=real64):: m_for_K
   Real(kind=real64):: f, g(n_params), H(n_params, n_params), f_best, g_best(n_params), H_best(n_params, n_params), dx(n_params)
   type(Dual64_2_5):: d_c, d_p, d_alpha, d_K, d_mu, fgh
   Integer(kind=kind(s%iter)):: iter_best
   Integer(kind=int64):: n, i
   Logical:: converge

   read(input_unit, *) normalize_interval
   read(input_unit, *) m_for_K
   read(input_unit, *) t_begin
   read(input_unit, *) t_end
   ASSERT(t_end >= t_begin)
   read(input_unit, *) c_p_alpha_K_mu_best
   read(input_unit, *) n
   allocate(ts(n))
   allocate(ms(n))
   do i = 1, n
      read(input_unit, *) ts(i), ms(i)
   end do
   m_max = maxval(ms)
   ms(:) = ms - m_for_K
   ASSERT(t_begin <= ts(1))
   ASSERT(ts(n) <= t_end)
   ts(:) = ts - t_begin
   t_len = t_end - t_begin

   call init(s, c_p_alpha_K_mu_best, max(minval(abs(c_p_alpha_K_mu_best))/10, 1d-3))

   f_best = huge(f_best)
   converge = .false.
   do
      dx = s%x - s%x_prev
      s%x = min(max(s%x, lower_bounds), upper_bounds)
      d_c = Dual64_2_5(s%x(1), [1, 0, 0, 0, 0])
      d_p = Dual64_2_5(s%x(2), [0, 1, 0, 0, 0])
      d_alpha = Dual64_2_5(s%x(3), [0, 0, 1, 0, 0])
      d_K = Dual64_2_5(s%x(4), [0, 0, 0, 1, 0])
      d_mu = Dual64_2_5(s%x(5), [0, 0, 0, 0, 1])
      fgh = -log_likelihood_etas(t_len, normalize_interval, d_c, d_p, d_alpha, d_K, d_mu, ts, ms)
      f = real(fgh)
      g = jaco(fgh)
      H = hess(fgh)
      write(output_unit, *) 'LOG: ', norm2(dx), s%is_convex, s%is_within, f, s%x, g
      if(f < f_best)then
         iter_best = s%iter
         c_p_alpha_K_mu_best = s%x
         f_best = f
         g_best = g
         H_best = H
      end if
      if(converge) exit
      call update(s, f, g, H, 'u')
      if(s%is_saddle_or_peak)then
         call random_number(s%x)
         s%x = (2*s%x - 1)*norm2(dx)
      end if
      converge = s%is_convex .and. s%is_within .and. norm2(g) <= 1d-6
   end do
   write(output_unit, '(a)') 'iterations'
   write(output_unit, '(g0)') s%iter
   write(output_unit, '(a)') 'm_max'
   write(output_unit, '(g0)') m_max
   write(output_unit, '(a)') 'iter_best'
   write(output_unit, '(g0)') iter_best
   write(output_unit, '(a)') 'best log-likelihood'
   write(output_unit, '(g0)') -f_best
   write(output_unit, '(a)') 'c, p, α, K, μ, K_for_other_programs, μ_for_other_programs'
   c = c_p_alpha_K_mu_best(1)
   p = c_p_alpha_K_mu_best(2)
   alpha = c_p_alpha_K_mu_best(3)
   K = c_p_alpha_K_mu_best(4)
   mu = c_p_alpha_K_mu_best(5)
   write(output_unit, '(g0, 6(" ", g0))') c, p, alpha, K, mu, utsu_seki(m_max - m_for_K, alpha)*K/omori_integrate(normalize_interval, c, p), mu/normalize_interval
   write(output_unit, '(a)') 'Jacobian'
   write(output_unit, '(g0, 4(" ", g0))') -g_best
   write(output_unit, '(a)') 'Hessian'
   do i = 1, 5
      write(output_unit, '(g0, 4(" ", g0))') -H_best(i, :)
   end do

   stop
end program main
