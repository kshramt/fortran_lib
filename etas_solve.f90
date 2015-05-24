program main
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit, real64, int64
   use, non_intrinsic:: ad_lib, only: Dual64_2_5, real
   use, non_intrinsic:: etas_lib, only: log_likelihood_etas

   implicit none

   Real(kind=real64), allocatable:: ts(:), ms(:)
   Real(kind=real64):: t_end, normalize_interval, c, p, alpha, k1, mu
   type(Dual64_2_5):: d_c, d_p, d_alpha, d_k1, d_mu
   Integer(kind=int64):: n, i, it1, it2, cr, cm

   t_end = 7
   normalize_interval = 1
   c = 1d-1
   p = 1
   alpha = 1
   mu = 10

   d_c = Dual64_2_5(c, [1, 0, 0, 0, 0])
   d_p = Dual64_2_5(p, [0, 1, 0, 0, 0])
   d_alpha = Dual64_2_5(alpha, [0, 0, 1, 0, 0])
   d_mu = Dual64_2_5(mu, [0, 0, 0, 0, 1])

   read(input_unit, *) n
   allocate(ts(n))
   allocate(ms(n))
   do i = 1, n
      read(input_unit, *) ts(i), ms(i)
   end do
   ms(:) = ms - ms(1)
   ts(:) = ts - ts(1)

   do i = 1, 10
      k1 = 10*i
      call system_clock(it1, cr, cm)
      write(output_unit, *) k1, log_likelihood_etas(t_end, normalize_interval, c, p, alpha, k1, mu, ts, ms)
      call system_clock(it2, cr, cm)
      write(output_unit, *) 'T:	', real(it2 - it1, kind=real64)/cr
   end do

   do i = 1, 10
      d_k1 = Dual64_2_5(10*i, [0, 0, 0, 1, 0])
      call system_clock(it1, cr, cm)
      write(output_unit, *) k1, real(log_likelihood_etas(t_end, normalize_interval, d_c, d_p, d_alpha, d_k1, d_mu, ts, ms))
      call system_clock(it2, cr, cm)
      write(output_unit, *) 'T:	', real(it2 - it1, kind=real64)/cr
   end do

   stop
end program main
