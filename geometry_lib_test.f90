#include "fortran_lib.h"
program main
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit
   use, intrinsic:: iso_fortran_env, only: int64, real64
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: geometry_lib

   implicit none

   Real(kind=real64):: pi = 2*atan2(1d0, 0d0)
   Real(kind=real64):: d
   Real(kind=real64):: th, th1, th2
   Integer(kind=int64):: i, j

   TEST(almost_equal(distance_2d([4d0, 3d0], [0d0, 25d0/3]), 5d0))
   TEST(almost_equal(distance_2d([4d0, 3d0], [-3d0, 25d0/3 + 4]), 5d0))
   TEST(almost_equal(distance_2d(-[4d0, 3d0], -[0d0, 25d0/3]), 5d0))
   TEST(almost_equal(distance_2d(-[4d0, 3d0], -[-3d0, 25d0/3 + 4]), 5d0))

   TEST(all(almost_equal(perpendicular_2d([4d0, 3d0], [0d0, 25d0/3]), [4d0, 3d0], rtol=2*epsilon(0d0))))
   TEST(all(almost_equal(perpendicular_2d([4d0, 3d0], [-3d0, 25d0/3 + 4]), [4d0, 3d0], rtol=2*epsilon(0d0))))
   TEST(all(almost_equal(perpendicular_2d(-[4d0, 3d0], -[0d0, 25d0/3]), -[4d0, 3d0], rtol=2*epsilon(0d0))))
   TEST(all(almost_equal(perpendicular_2d(-[4d0, 3d0], -[-3d0, 25d0/3 + 4]), -[4d0, 3d0], rtol=2*epsilon(0d0))))

   do i = 0, 16
      th1 = 2*i*pi/17
      do j = 0, 12
         th2 = 2*j*pi/13
         th = th2 - th1
         if(abs(th) > pi) th = sign(2*pi - abs(th), -th)
         TEST(almost_equal(angle_2d(2*[cos(th1), sin(th1)], 3*[cos(th2), sin(th2)]), th, atol=4*epsilon(0d0), rtol=4*epsilon(0d0)))
      end do
   end do


   call distance_and_angles_2d([-2/sqrt(3d0), 2d0], [2*sqrt(3d0), 2d0], d, th1, th2)
   TEST(almost_equal(d, 2d0))
   TEST(almost_equal(th1, pi/6))
   TEST(almost_equal(th2, -pi/3))

   write(output_unit, *) 'SUCCESS: ', __FILE__

   stop
end program main
