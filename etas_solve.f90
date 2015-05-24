program main
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit, real64, int64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: optimize_lib, only: NewtonStateRealDim0KindREAL64, init, update
   use, non_intrinsic:: ad_lib, only: Dual64_2_5, real, hess, jaco, operator(-)
   use, non_intrinsic:: etas_lib, only: log_likelihood_etas

   implicit none

   Real(kind=real64), allocatable:: ts(:), ms(:)
   type(NewtonStateRealDim0KindREAL64):: s
   Real(kind=real64):: c_p_alpha_k1_mu_best(5)
   Real(kind=real64):: t_end, normalize_interval
   Real(kind=real64):: f, g(5), H(5, 5), f_best
   type(Dual64_2_5):: c, p, alpha, k1, mu, fgh
   Integer(kind=int64):: n, i
   Logical:: converge

   read(input_unit, *) normalize_interval
   read(input_unit, *) t_end
   read(input_unit, *) c_p_alpha_k1_mu_best
   read(input_unit, *) n
   allocate(ts(n))
   allocate(ms(n))
   do i = 1, n
      read(input_unit, *) ts(i), ms(i)
   end do
   ms(:) = ms - ms(1)
   ts(:) = ts - ts(1)

   call init(s, c_p_alpha_k1_mu_best, max(minval(abs(c_p_alpha_k1_mu_best))/10, 1d-3))

   f_best = huge(f_best)
   do
      c = Dual64_2_5(c_p_alpha_k1_mu_best(1), [1, 0, 0, 0, 0])
      p = Dual64_2_5(c_p_alpha_k1_mu_best(2), [0, 1, 0, 0, 0])
      alpha = Dual64_2_5(c_p_alpha_k1_mu_best(3), [0, 0, 1, 0, 0])
      k1 = Dual64_2_5(c_p_alpha_k1_mu_best(4), [0, 0, 0, 1, 0])
      mu = Dual64_2_5(c_p_alpha_k1_mu_best(5), [0, 0, 0, 0, 1])
      ! todo: implement negation
      fgh = 0 - log_likelihood_etas(t_end, normalize_interval, c, p, alpha, k1, mu, ts, ms)
      f = real(fgh)
      g = jaco(fgh)
      H = hess(fgh)
      write(output_unit, *) s%is_convex, s%is_within, f, s%x, g
      call update(s, f, g, H, 'u')
      converge = all(almost_equal(c_p_alpha_k1_mu_best, s%x, relative=1d-6, absolute=1d-6)) .or. norm2(g) < 1d-6
      if(f < f_best)then
         c_p_alpha_k1_mu_best = s%x
         f_best = f
      end if
      if(converge) exit
   end do
   write(output_unit, *) s%iter, c_p_alpha_k1_mu_best

   stop
end program main
