#include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit
   use, intrinsic:: iso_fortran_env, only: int64, real64
   use, non_intrinsic:: etas_lib, only: intensity_etas

   implicit none

   Real(kind=real64), allocatable:: ts(:), ms(:)
   Real(kind=real64):: c, p, alpha, k1, mu
   Real(kind=real64):: normalize_interval
   Real(kind=real64):: t
   Integer(kind=int64):: i, n
   Integer:: ios

   read(input_unit, *) normalize_interval
   read(input_unit, *) c, p, alpha, k1, mu
   read(input_unit, *) n
   allocate(ts(n))
   allocate(ms(n))
   do i = 1, n
      read(input_unit, *) ts(i), ms(i)
   end do
   ms(:) = ms - ms(1)
   ts(:) = ts - ts(1)

   do
      read(input_unit, *, iostat=ios) t
      if(ios /= 0) exit
      write(output_unit, '(g0, "	", g0)') t, intensity_etas(t, normalize_interval, c, p, alpha, k1, mu, ts, ms)
   end do

   stop
end program main
