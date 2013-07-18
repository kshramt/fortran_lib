# include "utils.h"
program runner
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT, REAL128
   use, non_intrinsic:: character_lib, only: str, s
   use, non_intrinsic:: geodetic_lib, only: wgs84_from_ecef
   
   implicit none
   
   Real(kind = REAL128):: x, y, z
   Integer:: ios
   Character(len = 2**7):: format

   if(command_argument_count() >= 1)then
      write(OUTPUT_UNIT, *) 'Read x-y-z data from stdin and return lon-lat-height data to stdout.'
      write(OUTPUT_UNIT, *) 'Note that order is lon-lat, not lat-lon.'
      write(OUTPUT_UNIT, *) 'STDIN:'
      write(OUTPUT_UNIT, *) '  x, y, z: Coordinates in ECEF (m, m, m).'
      write(OUTPUT_UNIT, *) 'STDOUT:'
      write(OUTPUT_UNIT, *) '  lon, lat, height: Coordinates in WGS84 (deg, deg, m).'
      write(OUTPUT_UNIT, *) 'EXAMPLE:'
      write(OUTPUT_UNIT, *)
      write(OUTPUT_UNIT, *) 'cat <<EOF | get_wgs84_from_ecef.exe'
      write(OUTPUT_UNIT, *) '6412340.2 24129834 1234'
      write(OUTPUT_UNIT, *) '12470978 1284723 10987'
      write(OUTPUT_UNIT, *) 'EOF'
      write(OUTPUT_UNIT, *)

      stop
   end if

   format = '(3g' // str(precision(x) + 9) // '.' // str(precision(x)) // ')'
   do
      read(INPUT_UNIT, *, iostat = ios) x, y, z
      select case(ios)
      case(:-2)
         RAISE('Must not happen')
      case(-1) ! EOF
         exit
      case(0)
         write(OUTPUT_UNIT, s(format)) wgs84_from_ecef(x, y, z)
      case(1:)
         RAISE('Bad input')
      end select
   end do

   stop
end program runner
