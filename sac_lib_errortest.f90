# include "fortran_lib.h"
program main
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit
   use, non_intrinsic:: sac_lib

   implicit none


   Integer:: i


   read(input_unit, *) i


   select case(i)
   case(1)
      ! kevnm with too long argument
      block
         type(Sac):: wHead
         call set_kevnm(wHead, '123456789abcdefgh')
      end block
   case(2)
      ! kstnm with too long argument
      block
         type(Sac):: wHead
         call set_kstnm(wHead, '0123456789abcdefg')
      end block
   case(3)
      ! iftype with invalid argument
      block
         type(Sac):: wHead
         call set_iftype(wHead, 'anything other than enumerated values')
      end block
   case(4)
      ! imagsrc for undefined value
      block
         type(Sac):: wHead
         Character:: cTrash
         cTrash = get_imagsrc(wHead)
      end block
   case(5)
      ! iftype for undefined value
      block
         type(Sac):: wHead
         Character:: cTrash
         cTrash = get_iftype(wHead)
      end block
   case default
      write(output_unit, *) 4
   end select


   stop
end program main
