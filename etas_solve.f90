#include "fortran_lib.h"
module etas_solve
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: int64, real64
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit
   use, non_intrinsic:: ad_lib, only: Dual64_2_5, exp
   use, non_intrinsic:: constant_lib, only: get_infinity
   use, non_intrinsic:: etas_lib, only: EtasInputs64, load, index_ge

   implicit none

   private
   public:: load
   public:: exp_if_true

   Integer, parameter, public:: real_kind = real64
   Integer, parameter, public:: int_kind = int64
   Integer(kind=int_kind), parameter, public:: n_params = 5

   ! Interface
   interface load
      module procedure loadEtasSolveInputs
   end interface load

   interface exp_if_true
      module procedure exp_if_true_dual
      module procedure exp_if_true_real
   end interface exp_if_true

   type, public:: EtasSolveInputs
      Logical:: fixed(n_params)
      Logical:: by_log(n_params)
      Real(kind=real_kind):: initial(n_params) ! c, p, alpha, K, mu
      Real(kind=real_kind):: lower(n_params)
      Real(kind=real_kind):: upper(n_params)
      Logical, allocatable:: targets(:)
      Real(kind=real_kind):: t_begin
      Real(kind=real_kind):: gtol
      type(EtasInputs64):: ei
      Integer(kind=int_kind):: i_begin
   end type EtasSolveInputs

contains

   subroutine loadEtasSolveInputs(self, unit)
      Integer(kind=int_kind), parameter:: one = 1
      Integer(kind=kind(input_unit)), intent(in):: unit
      type(EtasSolveInputs), intent(out):: self
      Real(kind=real_kind):: m_fit_min

      read(unit, *) self%fixed
      read(unit, *) self%by_log
      read(unit, *) self%initial
      ASSERT(.not.any(self%initial <= 0 .and. self%by_log .and. self%fixed))
      ! there is no need to change fixed variables
      self%by_log = self%by_log .and. (.not.self%fixed)

      read(unit, *) self%lower
      read(unit, *) self%upper
      where(self%by_log) self%initial = log(self%initial)
      where(self%by_log) self%lower = log_or_neg_huge(self%lower)
      ASSERT(all(pack(self%upper > 0, self%by_log)))
      where(self%by_log) self%upper = log(self%upper)
      ASSERT(all((self%lower <= self%initial) .and. (self%initial <= self%upper)))

      read(unit, *) m_fit_min
      read(unit, *) self%t_begin
      read(unit, *) self%gtol
      ASSERT(self%gtol > 0)
      call load(self%ei, unit)
      self%i_begin = index_ge(self%ei%ts, self%t_begin, one, self%ei%n)
      ASSERT(self%ei%n - self%i_begin + 1 >= n_params)
      self%targets = self%ei%ms >= m_fit_min
   end subroutine loadEtasSolveInputs


   elemental function exp_if_true_dual(x, l) result(ret)
      type(Dual64_2_5), intent(in):: x
      Logical, intent(in):: l
      type(Dual64_2_5):: ret

      if(l)then
         ret = exp(x)
      else
         ret = x
      end if
   end function exp_if_true_dual


   elemental function exp_if_true_real(x, l) result(ret)
      Real(kind=real_kind), intent(in):: x
      Logical, intent(in):: l
      Real(kind=kind(x)):: ret

      if(l)then
         ret = exp(x)
      else
         ret = x
      end if
   end function exp_if_true_real


   elemental function log_or_neg_huge(x) result(ret)
      Real(kind=real_kind), intent(in):: x
      Real(kind=kind(x)):: ret

      if(x > 0)then
         ret = log(x)
      else
         ret = -get_infinity()
      end if
   end function log_or_neg_huge
end module etas_solve


program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit, real64, int64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: optimize_lib, only: BoundNewtonState64, init, update
   use, non_intrinsic:: ad_lib, only: Dual64_2_5, real, hess, jaco, operator(-), exp
   use, non_intrinsic:: etas_lib, only: log_likelihood_etas, omori_integrate, utsu_seki
   use, non_intrinsic:: etas_solve, only: n_params, EtasSolveInputs, load, exp_if_true, real_kind, int_kind

   implicit none

   type(EtasSolveInputs):: esi
   type(BoundNewtonState64):: s
   Real(kind=real_kind):: c_p_alpha_K_mu_best(n_params), c, p, alpha, K, mu
   Real(kind=real_kind):: f, g(n_params), H(n_params, n_params)
   Real(kind=real_kind):: f_best = huge(f_best), g_best(n_params), H_best(n_params, n_params)
   Real(kind=real_kind):: dx(n_params)
   type(Dual64_2_5):: d_c, d_p, d_alpha, d_K, d_mu, fgh
   Integer(kind=int_kind):: i
   Integer(kind=kind(s%iter)):: iter_best
   Logical:: converge = .false.
   Logical:: on_lower_best(n_params), on_upper_best(n_params)

   call load(esi, input_unit)
   esi%ei%ms(:) = esi%ei%ms - esi%ei%m_for_K
   c_p_alpha_K_mu_best(:) = esi%initial

   call init(s, c_p_alpha_K_mu_best, min(1d0, minval(esi%upper - esi%lower)/4), esi%lower, esi%upper)
   on_lower_best = s%on_lower
   on_upper_best = s%on_upper

   write(output_unit, '(a)') 'output_format_version: 1'
   do
      ! fix numerical error
      where(esi%fixed) s%x = esi%initial

      dx = s%x - s%x_prev

      d_c = exp_if_true(Dual64_2_5(s%x(1), [1, 0, 0, 0, 0]), esi%by_log(1))
      d_p = exp_if_true(Dual64_2_5(s%x(2), [0, 1, 0, 0, 0]), esi%by_log(2))
      d_alpha = exp_if_true(Dual64_2_5(s%x(3), [0, 0, 1, 0, 0]), esi%by_log(3))
      d_K = exp_if_true(Dual64_2_5(s%x(4), [0, 0, 0, 1, 0]), esi%by_log(4))
      d_mu = exp_if_true(Dual64_2_5(s%x(5), [0, 0, 0, 0, 1]), esi%by_log(5))
      fgh = -log_likelihood_etas(esi%t_begin, esi%ei%t_end, esi%ei%t_normalize_len, d_c, d_p, d_alpha, d_K, d_mu, esi%ei%ts, esi%ei%ms, esi%i_begin, esi%targets)
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
         on_lower_best = s%on_lower
         on_upper_best = s%on_upper
      end if
      if(converge) exit

      do i = 1, n_params
         if(esi%fixed(i))then
            g(i) = 0
            H(i, :) = 0
            H(:, i) = 0
            H(i, i) = 1
         end if
      end do

      call update(s, f, g, H, 'u')
      if(s%is_saddle_or_peak)then
         call random_number(s%x)
         s%x = (2*s%x - 1)*norm2(dx)
      end if
      converge = s%is_at_corner .or. (all(abs(pack(g, .not.(s%on_lower .or. s%on_upper))) <= esi%gtol) .and. all(pack(g, s%on_lower) >= 0) .and. all(pack(g, s%on_upper) <= 0))
   end do

   write(output_unit, '(a)') 'iterations'
   write(output_unit, '(g0)') s%iter
   write(output_unit, '(a)') 'iter_best'
   write(output_unit, '(g0)') iter_best
   write(output_unit, '(a)') 'best log-likelihood'
   write(output_unit, '(g0)') -f_best
   write(output_unit, '(a)') 'c, p, α, K, μ, K_for_other_programs, μ_for_other_programs'
   c = exp_if_true(c_p_alpha_K_mu_best(1), esi%by_log(1))
   p = exp_if_true(c_p_alpha_K_mu_best(2), esi%by_log(2))
   alpha = exp_if_true(c_p_alpha_K_mu_best(3), esi%by_log(3))
   K = exp_if_true(c_p_alpha_K_mu_best(4), esi%by_log(4))
   mu = exp_if_true(c_p_alpha_K_mu_best(5), esi%by_log(5))
   write(output_unit, '(g0, 6(" ", g0))') c, p, alpha, K, mu, K/omori_integrate(esi%ei%t_normalize_len, c, p), mu/esi%ei%t_normalize_len
   write(output_unit, '(a)') 'Jacobian'
   write(output_unit, '(g0, 4(" ", g0))') -g_best
   write(output_unit, '(a)') 'Hessian'
   do i = 1, 5
      write(output_unit, '(g0, 4(" ", g0))') -H_best(i, :)
   end do
   write(output_unit, '(a)') 'fixed'
   write(output_unit, '(g0, 6(" ", g0))') esi%fixed
   write(output_unit, '(a)') 'on_lower'
   write(output_unit, '(g0, 6(" ", g0))') on_lower_best
   write(output_unit, '(a)') 'on_upper'
   write(output_unit, '(g0, 6(" ", g0))') on_upper_best

   stop
end program main
