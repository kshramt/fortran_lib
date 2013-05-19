# include "utils.h"
program geodetic_lib_test
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: OUTPUT_UNIT, REAL128
   use, non_intrinsic:: comparable_lib, only: equivalent
   use, non_intrinsic:: geodetic_lib

   implicit none
   Real(kind = REAL128):: lonLatH(1:3)
   Real(kind = kind(lonLatH)), parameter:: ZERO = 0, ONE = 1

   lonLatH = wgs84_from_ecef(ONE, ZERO, ZERO)
   TEST(lonLatH(1) == 0)
   TEST(lonLatH(2) == 0)
   lonLatH = wgs84_from_ecef(-ONE, ZERO, ZERO)
   TEST(lonLatH(1) == 180)
   TEST(lonLatH(2) == 0)
   lonLatH = wgs84_from_ecef(ONE, ONE, ZERO)
   TEST(lonLatH(1) == 45)
   TEST(lonLatH(2) == 0)
   lonLatH = wgs84_from_ecef(ONE, -ONE, ZERO)
   TEST(lonLatH(1) == -45)
   TEST(lonLatH(2) == 0)
   lonLatH = wgs84_from_ecef(ONE, ZERO, ONE)
   TEST(lonLatH(1) == 0)
   TEST(lonLatH(2) > 0)
   lonLatH = wgs84_from_ecef(ONE, ZERO, -ONE)
   TEST(lonLatH(1) == 0)
   TEST(lonLatH(2) < 0)

   lonLatH = wgs84_from_ecef(0.1e-14_REAL128, 0.0_REAL128, 1000.0_REAL128)
   TEST(lonLatH(2) < 90) ! DEBUG
   TEST(lonLatH(2) > real(89, kind = kind(lonLatH)))

   lonLatH = wgs84_from_ecef(0.1e-15_REAL128, 0.0_REAL128, 1000.0_REAL128)
   TEST(lonLatH(2) == 90)

   lonLatH = wgs84_from_ecef(0.1e-14_REAL128, 0.0_REAL128, -1000.0_REAL128)
   TEST(lonLatH(2) > -90) ! DEBUG
   TEST(lonLatH(2) < real(-89, kind = kind(lonLatH)))

   lonLatH = wgs84_from_ecef(0.1e-15_REAL128, 0.0_REAL128, -1000.0_REAL128)
   TEST(lonLatH(2) == -90)

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program geodetic_lib_test
