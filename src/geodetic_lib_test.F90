# include "utils.h"
program geodetic_lib_test
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: OUTPUT_UNIT, REAL64, REAL128
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: geodetic_lib

   implicit none
   Real(kind = REAL64):: xyz64(1:3)
   Real(kind = REAL128):: lonLatH128(1:3)
   Real(kind = kind(xyz64)), parameter:: ZERO64 = 0, ONE64 = 1
   Real(kind = kind(lonLatH128)), parameter:: ZERO128 = 0, ONE128 = 1

   ! ecef_from_wgs84
   xyz64 = ecef_from_wgs84(0.0_REAL64, 0.0_REAL64, 0.0_REAL64)
   TEST(almost_equal(xyz64(1), WGS84_A))
   TEST(almost_equal(xyz64(2), ZERO64))
   TEST(almost_equal(xyz64(3), ZERO64))

   xyz64 = ecef_from_wgs84(0.0_REAL64, 90.0_REAL64, 0.0_REAL64)
   TEST(abs(xyz64(1)) < sqrt(epsilon(xyz64(1))))
   TEST(abs(xyz64(2)) < sqrt(epsilon(xyz64(2))))
   TEST(almost_equal(xyz64(3), WGS84_B))

   ! wgs84_from_ecef
   lonLatH128 = wgs84_from_ecef(ZERO128, ZERO128, ZERO128)
   TEST(almost_equal(lonLatH128(1), ZERO128))
   TEST(lonLatH128(2) > 89)

   lonLatH128 = wgs84_from_ecef(ONE128*6000000, ZERO128, ZERO128)
   TEST(almost_equal(lonLatH128(1), ZERO128))
   TEST(abs(lonLatH128(2)) < sqrt(epsilon(lonLatH128(2))))
   lonLatH128 = wgs84_from_ecef(-ONE128*6000000, ZERO128, ZERO128)
   TEST(lonLatH128(1) == 180)
   TEST(abs(lonLatH128(2)) < sqrt(epsilon(lonLatH128(2))))
   lonLatH128 = wgs84_from_ecef(ONE128*6000000, ONE128*6000000, ZERO128)
   TEST(lonLatH128(1) == 45)
   TEST(abs(lonLatH128(2)) < sqrt(epsilon(lonLatH128(2))))
   lonLatH128 = wgs84_from_ecef(ONE128*6000000, -ONE128*6000000, ZERO128)
   TEST(lonLatH128(1) == -45)
   TEST(abs(lonLatH128(2)) < sqrt(epsilon(lonLatH128(2))))
   lonLatH128 = wgs84_from_ecef(ONE128, ZERO128, ONE128)
   TEST(lonLatH128(1) == 0)
   TEST(lonLatH128(2) >= 0)
   lonLatH128 = wgs84_from_ecef(ONE128, ZERO128, -ONE128)
   TEST(lonLatH128(1) == 0)
   TEST(lonLatH128(2) <= 0)

   lonLatH128 = wgs84_from_ecef(epsilon(ONE128), ZERO128, ZERO128)
   TEST(lonLatH128(2) > 89)

   lonLatH128 = wgs84_from_ecef(ONE128*6380000, ZERO128, ONE128*1000000)
   TEST(lonLatH128(2) < 45) ! Debug

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program geodetic_lib_test
