#include "fortran_lib.h"
module etas_solve
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: int64, real64
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit
   use, non_intrinsic:: ad_lib, only: Dual64_2_5
   use, non_intrinsic:: etas_lib, only: EtasInputs64, load, index_ge

   implicit none

   private
   public:: load
   public:: new_value

   Integer, parameter, public:: real_kind = real64
   Integer, parameter, public:: int_kind = int64
   Integer(kind=int_kind), parameter, public:: n_params = 5

   ! Interface
   interface load
      module procedure loadEtasSolveInputs
   end interface load

   interface new_value
      module procedure new_value
   end interface new_value


   type, public:: EtasSolveInputs
      Logical:: fixed(n_params)
      Real(kind=real_kind):: initial(n_params) ! c, p, alpha, K, mu
      Real(kind=real_kind):: lower_bounds(n_params)
      Real(kind=real_kind):: upper_bounds(n_params)
      Real(kind=real_kind):: t_begin
      type(EtasInputs64):: ei
      Integer(kind=int_kind):: i_begin
   end type EtasSolveInputs

contains

   subroutine loadEtasSolveInputs(self, unit)
      Integer(kind=int_kind), parameter:: one = 1
      Integer(kind=kind(input_unit)), intent(in):: unit
      type(EtasSolveInputs), intent(out):: self

      read(unit, *) self%fixed
      read(unit, *) self%initial
      read(unit, *) self%lower_bounds
      read(unit, *) self%upper_bounds
      ASSERT(all((self%lower_bounds <= self%initial) .and. (self%initial <= self%upper_bounds)))
      read(unit, *) self%t_begin
      call load(self%ei, unit)
      self%i_begin = index_ge(self%ei%ts, self%t_begin, one, self%ei%n)
      ASSERT(self%ei%n - self%i_begin + 1 >= n_params)
   end subroutine loadEtasSolveInputs


   function new_value(i, xs) result(ret)
      type(Dual64_2_5):: ret
      Integer(kind=int_kind), intent(in):: i
      Real(kind=real_kind), intent(in):: xs(:)

      ret%f = xs(i)
      ret%g(i) = 1
   end function new_value
end module etas_solve


program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit, real64, int64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: optimize_lib, only: BoundNewtonState64, init, update
   use, non_intrinsic:: ad_lib, only: Dual64_2_5, real, hess, jaco, operator(-), exp
   use, non_intrinsic:: etas_lib, only: log_likelihood_etas, omori_integrate, utsu_seki
   use, non_intrinsic:: etas_solve, only: n_params, EtasSolveInputs, load, new_value, real_kind, int_kind

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
   ASSERT(.not.all(esi%fixed))
   esi%ei%ms(:) = esi%ei%ms - esi%ei%m_for_K
   c_p_alpha_K_mu_best(:) = esi%initial

   call init(s, c_p_alpha_K_mu_best, max(minval(abs(c_p_alpha_K_mu_best))/10, 1d-3), esi%lower_bounds, esi%upper_bounds)
   on_lower_best = s%on_lower
   on_upper_best = s%on_upper

   do
      ! fix numerical error
      where(esi%fixed) s%x = esi%initial

      dx = s%x - s%x_prev

      d_c = new_value(1_int_kind, s%x)
      d_p = new_value(2_int_kind, s%x)
      d_alpha = new_value(3_int_kind, s%x)
      d_K = new_value(4_int_kind, s%x)
      d_mu = new_value(5_int_kind, s%x)
      fgh = -log_likelihood_etas(esi%t_begin, esi%ei%t_end, esi%ei%t_normalize_len, d_c, d_p, d_alpha, d_K, d_mu, esi%ei%ts, esi%ei%ms, esi%i_begin)
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
            H(i, i) = 2**10
         end if
      end do

      call update(s, f, g, H, 'u')
      if(s%is_saddle_or_peak)then
         call random_number(s%x)
         s%x = (2*s%x - 1)*norm2(dx)
      end if
      converge = s%is_at_corner .or. all(abs(pack(g, .not.(s%on_lower .or. s%on_upper))) <= 1d-6)
   end do

   write(output_unit, '(a)') 'iterations'
   write(output_unit, '(g0)') s%iter
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
   write(output_unit, '(g0, 6(" ", g0))') esi%fixed
   write(output_unit, '(g0, 6(" ", g0))') on_lower_best
   write(output_unit, '(g0, 6(" ", g0))') on_upper_best
   write(output_unit, '(g0, 6(" ", g0))') c, p, alpha, K, mu, K/omori_integrate(esi%ei%t_normalize_len, c, p), mu/esi%ei%t_normalize_len
   write(output_unit, '(a)') 'Jacobian'
   write(output_unit, '(g0, 4(" ", g0))') -g_best
   write(output_unit, '(a)') 'Hessian'
   do i = 1, 5
      write(output_unit, '(g0, 4(" ", g0))') -H_best(i, :)
   end do

   stop
end program main
