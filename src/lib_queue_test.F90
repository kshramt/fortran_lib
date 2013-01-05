#include "utils.h"
program lib_queue_test
  USE_UTILS_H
  use, intrinsic:: iso_fortran_env, only:OUTPUT_UNIT
  use lib_queue, only: IntegerDim0KindINT32Queue, IntegerDim1KindINT32Queue, IntegerDim2KindINT32Queue
  use lib_queue, only: push, shift

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
  test(.not.isSuccess)
  call push(queue0, 1)
  call push(queue0, 2)
  call push(queue0, 3)
  call push(queue0, 4)
  call push(queue0, 5)
  isSuccess = shift(queue0, val0)
  test(isSuccess)
  test(val0 == 1)
  isSuccess = shift(queue0, val0)
  test(isSuccess)
  test(val0 == 2)
  isSuccess = shift(queue0, val0)
  test(isSuccess)
  test(val0 == 3)
  isSuccess = shift(queue0, val0)
  test(isSuccess)
  test(val0 == 4)
  isSuccess = shift(queue0, val0)
  test(isSuccess)
  test(val0 == 5)
  isSuccess = shift(queue0, val0)
  test(.not.isSuccess)
  isSuccess = shift(queue0, val0)
  test(.not.isSuccess)

  ! dim = 0
  isSuccess = shift(queue1, val1)
  test(.not.isSuccess)
  call push(queue1, [1])
  call push(queue1, [2])
  call push(queue1, [3, 0, -3])
  call push(queue1, [4])
  call push(queue1, [5])
  isSuccess = shift(queue1, val1)
  test(isSuccess)
  test(all(val1 == [1]))
  isSuccess = shift(queue1, val1)
  test(isSuccess)
  test(all(val1 == [2]))
  isSuccess = shift(queue1, val1)
  test(isSuccess)
  test(all(val1 == [3, 0, -3]))
  isSuccess = shift(queue1, val1)
  test(isSuccess)
  test(all(val1 == [4]))
  isSuccess = shift(queue1, val1)
  test(isSuccess)
  test(all(val1 == [5]))
  isSuccess = shift(queue1, val1)
  test(.not.isSuccess)
  isSuccess = shift(queue1, val1)
  test(.not.isSuccess)

  ! dim 2
  call push(queue2, reshape([1, 2, 3, 4, 5, 6], [2, 3]))
  call push(queue2, reshape([1, 2, 3, 4, 5, 6, 7, 8], [4, 2]))
  isSuccess = shift(queue2, val2)
  test(isSuccess)
  test(all(shape(val2) == [2, 3]))
  isSuccess = shift(queue2, val2)
  test(isSuccess)
  test(all(shape(val2) == [4, 2]))

  ! Many times
  do i = 1, N
    call push(queue0, i)
  end do
  do i = 1, N - 1
    isSuccess = shift(queue0, val0)
  end do
  isSuccess = shift(queue0, val0)
  test(isSuccess)
  test(val0 == N)

  write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

  stop
end program lib_queue_test
