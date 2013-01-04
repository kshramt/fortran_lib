#include "utils.h"
program lib_stack_test
  USE_UTILS_H
  use, intrinsic:: iso_fortran_env, only:OUTPUT_UNIT
  use lib_stack, only: IntegerDim0KindINT32Stack
  use lib_stack, only: push, pop

  implicit none

  type(IntegerDim0KindINT32Stack):: stack
  Integer:: val
  Logical:: isSuccess
  Integer:: i
  Integer, parameter:: N = 5000

  isSuccess = pop(stack, val)
  test(.not.isSuccess)
  call push(stack, 1)
  call push(stack, 2)
  call push(stack, 3)
  call push(stack, 4)
  call push(stack, 5)
  isSuccess = pop(stack, val)
  test(isSuccess)
  test(val == 5)
  isSuccess = pop(stack, val)
  test(isSuccess)
  test(val == 4)
  isSuccess = pop(stack, val)
  test(isSuccess)
  test(val == 3)
  isSuccess = pop(stack, val)
  test(isSuccess)
  test(val == 2)
  isSuccess = pop(stack, val)
  test(isSuccess)
  test(val == 1)
  isSuccess = pop(stack, val)
  test(.not.isSuccess)
  isSuccess = pop(stack, val)
  test(.not.isSuccess)

  write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

  stop
end program lib_stack_test
