#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit, real64, int64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: optimize_lib, only: NewtonState64, init, update
   use, non_intrinsic:: ad_lib, only: Dual64_2_5, real, hess, jaco, operator(-), exp
   use, non_intrinsic:: etas_lib, only: log_likelihood_etas, omori_integrate

   implicit none

   Integer(kind=int64), parameter:: n_params = 5
   Real(kind=real64), parameter:: lower_bounds(n_params) = [1d-8, -huge(0d0), -huge(0d0), 0d0, 1d-8]
   Real(kind=real64), parameter:: upper_bounds(n_params) = [10d0, 10d0, 10d0, huge(0d0), huge(0d0)]
   Real(kind=real64), allocatable:: ts(:), ms(:)
   Real(kind=real64):: M_max
   type(NewtonState64):: s
   Real(kind=real64):: c_p_alpha_K_mu_best(n_params)
   Real(kind=real64):: t_begin, t_end, t_len, normalize_interval
   Real(kind=real64):: f, g(n_params), H(n_params, n_params), f_best, H_best(n_params, n_params), bound, dx(n_params)
   type(Dual64_2_5):: c, p, alpha, K, mu, fgh
   Integer(kind=int64):: n, i
   Logical:: converge

   read(input_unit, *) normalize_interval
   read(input_unit, *) t_begin
   read(input_unit, *) t_end
   ASSERT(t_end >= t_begin)
   do i = 1, n_params
      read(input_unit, *) c_p_alpha_K_mu_best(i)
   end do
   read(input_unit, *) n
   allocate(ts(n))
   allocate(ms(n))
   do i = 1, n
      read(input_unit, *) ts(i), ms(i)
   end do
   M_max = maxval(ms)
   ms(:) = ms - M_max
   ts(:) = ts - t_begin
   ASSERT(ts(1) >= 0)
   t_len = t_end - t_begin

   call init(s, c_p_alpha_K_mu_best, max(minval(abs(c_p_alpha_K_mu_best))/10, 1d-3))

   f_best = huge(f_best)
   do
      dx = s%x - s%x_prev
      do i = 1, n_params
         if(s%x(i) < lower_bounds(i))then
            bound = (lower_bounds(i) - s%x_prev(i))/dx(i)
            DEBUG_PRINT_VARIABLE(i)
            DEBUG_PRINT_VARIABLE(bound)
            s%x(i) = bound*dx(i) + s%x_prev(i)
         ! else if(s%x(i) > upper_bounds(i))then
         !    bound = (upper_bounds(i) - s%x_prev(i))/dx(i)
         !    DEBUG_PRINT_VARIABLE(i)
         !    DEBUG_PRINT_VARIABLE(bound)
         !    s%x(i) = bound*dx(i) + s%x_prev(i)
         end if
      end do
      c = Dual64_2_5(s%x(1), [1, 0, 0, 0, 0])
      p = Dual64_2_5(s%x(2), [0, 1, 0, 0, 0])
      alpha = Dual64_2_5(s%x(3), [0, 0, 1, 0, 0])
      K = Dual64_2_5(s%x(4), [0, 0, 0, 1, 0])
      mu = Dual64_2_5(s%x(5), [0, 0, 0, 0, 1])
      fgh = -log_likelihood_etas(t_len, normalize_interval, c, p, alpha, K, mu, ts, ms)
      f = real(fgh)
      g = jaco(fgh)
      H = hess(fgh)
      write(error_unit, *) norm2(dx), s%is_convex, s%is_within, f, s%x, g
      call update(s, f, g, H, 'u')
      if(s%is_saddle_or_peak)then
         call random_number(s%x)
         s%x = (2*s%x - 1)*norm2(dx)
      end if
      converge = s%is_convex .and. s%is_within .and. (all(almost_equal(c_p_alpha_K_mu_best, s%x, relative=1d-6, absolute=1d-6)) .or. norm2(g) < 1d-6)
      if(f < f_best)then
         c_p_alpha_K_mu_best = s%x
         f_best = f
         H_best = H
      end if
      if(converge) exit
   end do
   write(output_unit, '(a)') 'iterations'
   write(output_unit, '(g0)') s%iter
   write(output_unit, '(a)') 'M_max'
   write(output_unit, '(g0)') M_max
   write(output_unit, '(a)') 'best log-likelihood'
   write(output_unit, '(g0)') -f_best
   write(output_unit, '(a)') 'c, p, α, K, μ, K_for_other_programs, μ_for_other_programs'
   write(output_unit, '(g0, 6("	", g0))') c_p_alpha_K_mu_best, c_p_alpha_K_mu_best(4)/omori_integrate(normalize_interval, c_p_alpha_K_mu_best(1), c_p_alpha_K_mu_best(2)), c_p_alpha_K_mu_best(5)/normalize_interval
   write(output_unit, '(a)') 'Hessian'
   do i = 1, 5
      write(output_unit, '(g0, 4("	", g0))') -H_best(i, :)
   end do

   stop
end program main
