#include "utils.h"
program queue_lib_test
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only:OUTPUT_UNIT
   use, non_intrinsic:: queue_lib, only: IntegerDim0KindINT32Queue, IntegerDim1KindINT32Queue, IntegerDim2KindINT32Queue
   use, non_intrinsic:: queue_lib, only: push, shift

   implicit none

   type(IntegerDim0KindINT32Queue):: queue0
   type(IntegerDim1KindINT32Queue):: queue1
   type(IntegerDim2KindINT32Queue):: queue2
   Integer:: val0
   Integer, allocatable:: val1(:)
   Integer, allocatable:: val2(:, :)
   Logical:: isSuccess
   Integer:: i
   Integer, parameter:: N = 1000000

   ! dim = 0
   isSuccess = shift(queue0, val0)
   TEST(.not.isSuccess)
   call push(queue0, 1)
   call push(queue0, 2)
   call push(queue0, 3)
   call push(queue0, 4)
   call push(queue0, 5)
   isSuccess = shift(queue0, val0)
   TEST(isSuccess)
   TEST(val0 == 1)
   isSuccess = shift(queue0, val0)
   TEST(isSuccess)
   TEST(val0 == 2)
   isSuccess = shift(queue0, val0)
   TEST(isSuccess)
   TEST(val0 == 3)
   isSuccess = shift(queue0, val0)
   TEST(isSuccess)
   TEST(val0 == 4)
   isSuccess = shift(queue0, val0)
   TEST(isSuccess)
   TEST(val0 == 5)
   isSuccess = shift(queue0, val0)
   TEST(.not.isSuccess)
   isSuccess = shift(queue0, val0)
   TEST(.not.isSuccess)

   ! dim = 0
   isSuccess = shift(queue1, val1)
   TEST(.not.isSuccess)
   call push(queue1, [1])
   call push(queue1, [2])
   call push(queue1, [3, 0, -3])
   call push(queue1, [4])
   call push(queue1, [5])
   isSuccess = shift(queue1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [1]))
   isSuccess = shift(queue1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [2]))
   isSuccess = shift(queue1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [3, 0, -3]))
   isSuccess = shift(queue1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [4]))
   isSuccess = shift(queue1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [5]))
   isSuccess = shift(queue1, val1)
   TEST(.not.isSuccess)
   isSuccess = shift(queue1, val1)
   TEST(.not.isSuccess)

   ! dim 2
   call push(queue2, reshape([1, 2, 3, 4, 5, 6], [2, 3]))
   call push(queue2, reshape([1, 2, 3, 4, 5, 6, 7, 8], [4, 2]))
   isSuccess = shift(queue2, val2)
   TEST(isSuccess)
   TEST(all(shape(val2) == [2, 3]))
   isSuccess = shift(queue2, val2)
   TEST(isSuccess)
   TEST(all(shape(val2) == [4, 2]))

   ! Many times
   do i = 1, N
      call push(queue0, i)
   end do
   do i = 1, N - 1
      isSuccess = shift(queue0, val0)
   end do
   isSuccess = shift(queue0, val0)
   TEST(isSuccess)
   TEST(val0 == N)

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program queue_lib_test
