# include "utils.h"
program geodetic_lib_test
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: OUTPUT_UNIT, REAL128
   use, non_intrinsic:: comparable_lib, only: equivalent
   use, non_intrinsic:: geodetic_lib

   implicit none
   Real(kind = REAL128):: lonLatH128(1:3)
   Real(kind = kind(lonLatH128)), parameter:: ZERO128 = 0, ONE128 = 1

   lonLatH128 = wgs84_from_ecef(ONE128, ZERO128, ZERO128)
   TEST(lonLatH128(1) == 0)
   TEST(lonLatH128(2) == 0)
   lonLatH128 = wgs84_from_ecef(-ONE128, ZERO128, ZERO128)
   TEST(lonLatH128(1) == 180)
   TEST(lonLatH128(2) == 0)
   lonLatH128 = wgs84_from_ecef(ONE128, ONE128, ZERO128)
   TEST(lonLatH128(1) == 45)
   TEST(lonLatH128(2) == 0)
   lonLatH128 = wgs84_from_ecef(ONE128, -ONE128, ZERO128)
   TEST(lonLatH128(1) == -45)
   TEST(lonLatH128(2) == 0)
   lonLatH128 = wgs84_from_ecef(ONE128, ZERO128, ONE128)
   TEST(lonLatH128(1) == 0)
   TEST(lonLatH128(2) > 0)
   lonLatH128 = wgs84_from_ecef(ONE128, ZERO128, -ONE128)
   TEST(lonLatH128(1) == 0)
   TEST(lonLatH128(2) < 0)
   lonLatH128 = wgs84_from_ecef(0.1e-13_REAL128, 0.0_REAL128, 1000.0_REAL128)
   TEST(lonLatH128(2) < 90) ! DEBUG
   TEST(lonLatH128(2) > real(89, kind = kind(lonLatH128)))

   lonLatH128 = wgs84_from_ecef(0.1e-15_REAL128, 0.0_REAL128, 1000.0_REAL128)
   TEST(lonLatH128(2) == 90)

   lonLatH128 = wgs84_from_ecef(0.1e-14_REAL128, 0.0_REAL128, -1000.0_REAL128)
   TEST(lonLatH128(2) > -90) ! DEBUG
   TEST(lonLatH128(2) < real(-89, kind = kind(lonLatH128)))

   lonLatH128 = wgs84_from_ecef(0.1e-15_REAL128, 0.0_REAL128, -1000.0_REAL128)
   TEST(lonLatH128(2) == -90)

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program geodetic_lib_test
