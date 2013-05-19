# include "utils.h"
program geodetic_lib_test
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: OUTPUT_UNIT, REAL64, REAL128
   use, non_intrinsic:: comparable_lib, only: equivalent
   use, non_intrinsic:: geodetic_lib

   implicit none
   Real(kind = REAL64):: lonLatH64(1:3)
   Real(kind = REAL128):: lonLatH128(1:3)
   Real(kind = kind(lonLatH64)), parameter:: ZERO64 = 0, ONE64 = 1
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

   lonLatH64 = ecef_from_wgs84(0.0_REAL64, 0.0_REAL64, 0.0_REAL64)
   TEST(equivalent(lonLatH64(1), WGS84_A))
   TEST(equivalent(lonLatH64(2), ZERO64))
   TEST(equivalent(lonLatH64(3), ZERO64))

   lonLatH64 = ecef_from_wgs84(0.0_REAL64, 90.0_REAL64, 0.0_REAL64)
   TEST(abs(lonLatH64(1)) < 1e-7)
   TEST(abs(lonLatH64(2)) < 1e-7)
   TEST(equivalent(lonLatH64(3), WGS84_B))

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
