#include "utils.h"
program lib_stack_test
  USE_UTILS_H
  use, intrinsic:: iso_fortran_env, only:OUTPUT_UNIT
  use lib_stack, only: IntegerDim0KindINT32Stack, IntegerDim1KindINT32Stack
  use lib_stack, only: push, pop

  implicit none

  type(IntegerDim0KindINT32Stack):: stack0
  type(IntegerDim1KindINT32Stack):: stack1
  Integer:: val0
  Integer, allocatable:: val1(:)
  Logical:: isSuccess

  ! dim = 0
  isSuccess = pop(stack0, val0)
  test(.not.isSuccess)
  call push(stack0, 1)
  call push(stack0, 2)
  call push(stack0, 3)
  call push(stack0, 4)
  call push(stack0, 5)
  isSuccess = pop(stack0, val0)
  test(isSuccess)
  test(val0 == 5)
  isSuccess = pop(stack0, val0)
  test(isSuccess)
  test(val0 == 4)
  isSuccess = pop(stack0, val0)
  test(isSuccess)
  test(val0 == 3)
  isSuccess = pop(stack0, val0)
  test(isSuccess)
  test(val0 == 2)
  isSuccess = pop(stack0, val0)
  test(isSuccess)
  test(val0 == 1)
  isSuccess = pop(stack0, val0)
  test(.not.isSuccess)
  isSuccess = pop(stack0, val0)
  test(.not.isSuccess)

  ! dim = 0
  isSuccess = pop(stack1, val1)
  test(.not.isSuccess)
  call push(stack1, [1])
  call push(stack1, [2])
  call push(stack1, [3, 0, -3])
  call push(stack1, [4])
  call push(stack1, [5])
  isSuccess = pop(stack1, val1)
  test(isSuccess)
  test(all(val1 == [5]))
  isSuccess = pop(stack1, val1)
  test(isSuccess)
  test(all(val1 == [4]))
  isSuccess = pop(stack1, val1)
  test(isSuccess)
  test(all(val1 == [3, 0, -3]))
  isSuccess = pop(stack1, val1)
  test(isSuccess)
  test(all(val1 == [2]))
  isSuccess = pop(stack1, val1)
  test(isSuccess)
  test(all(val1 == [1]))
  isSuccess = pop(stack1, val1)
  test(.not.isSuccess)
  isSuccess = pop(stack1, val1)
  test(.not.isSuccess)

  write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

  stop
end program lib_stack_test
