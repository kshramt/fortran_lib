program main
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit, int64, real64
   use, non_intrinsic:: etas_lib, only: log_likelihood_etas

   implicit none

   Integer(kind=int64):: n
   Real(kind=real64), allocatable:: ts(:), ms(:)
   Integer(kind=kind(n)):: i, j
   Real(kind=kind(ts)):: t_end, normalize_interval, c, p, alpha, k1, mu

   t_end = 7
   normalize_interval = 1
   c = 1d0/24
   alpha = 1
   mu = 100

   read(input_unit, *) n
   allocate(ts(n))
   allocate(ms(n))
   do i = 1, n
      read(input_unit, *) ts(i), ms(i)
   end do
   ts(:) = ts - ts(1)
   ms(:) = ms - ms(1)

   do i = 1, 5
      p = (i + 1)*1d-1
      do j = 1, 5
         k1 = 100 + j*4d0
         write(output_unit, *) p, k1, log_likelihood_etas(t_end, normalize_interval, c, p, alpha, k1, mu, ts, ms)
      end do
   end do

   stop
end program main
