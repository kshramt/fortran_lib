# include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit
   use, intrinsic:: iso_fortran_env, only: int32
   use, non_intrinsic:: io_lib

   implicit none

   Integer:: i


   read(input_unit, *) i


   select case(i)
   case(1)
      ! illegal argument for form
      block
         Integer(int32):: unit
         call mktemp(unit, form='illegal')
      end block
   case default
      write(output_unit, *) 1
   end select


   stop
end program main
