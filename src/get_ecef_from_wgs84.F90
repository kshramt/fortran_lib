# include "utils.h"
program runner
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT, REAL128
   use, non_intrinsic:: character_lib, only: str, s
   use, non_intrinsic:: geodetic_lib, only: ecef_from_wgs84
   
   implicit none
   
   Real(kind = REAL128):: lon, lat, h
   Integer:: ios
   Character(len = 2**7):: format

   if(command_argument_count() >= 1)then
      write(OUTPUT_UNIT, *) 'Read lon-lat-height data from stdin and return x-y-z data to stdout.'
      write(OUTPUT_UNIT, *) 'Note that order is lon-lat, not lat-lon.'
      write(OUTPUT_UNIT, *) 'STDIN:'
      write(OUTPUT_UNIT, *) '  lon, lat, height: Coordinates in WGS84 (deg, deg, m).'
      write(OUTPUT_UNIT, *) 'STDOUT:'
      write(OUTPUT_UNIT, *) '  x, y, z: Coordinates in ECEF (m, m, m).'
      write(OUTPUT_UNIT, *) 'EXAMPLE:'
      write(OUTPUT_UNIT, *)
      write(OUTPUT_UNIT, *) 'cat <<EOF | get_ecef_from_wgs84.exe'
      write(OUTPUT_UNIT, *) '32.2 32.1 239812'
      write(OUTPUT_UNIT, *) '-122.2 -32 12470978'
      write(OUTPUT_UNIT, *) 'EOF'
      write(OUTPUT_UNIT, *)

      stop
   end if

   format = '(3g' // str(precision(lon) + 9) // '.' // str(precision(lon)) // ')'
   do
      read(INPUT_UNIT, *, iostat = ios) lon, lat, h
      select case(ios)
      case(:-2)
         RAISE('Must not happen')
      case(-1) ! EOF
         exit
      case(0)
         write(OUTPUT_UNIT, s(format)) ecef_from_wgs84(lon, lat, h)
      case(1:)
         RAISE('Bad input')
      end select
   end do

   stop
end program runner
