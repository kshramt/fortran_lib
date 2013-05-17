#include "utils.h"
program stack_lib_test
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only:OUTPUT_UNIT
   use, non_intrinsic:: stack_lib, only: IntegerDim0KindINT32Stack, IntegerDim1KindINT32Stack, IntegerDim2KindINT32Stack
   use, non_intrinsic:: stack_lib, only: push_stack, pop_stack

   implicit none

   type(IntegerDim0KindINT32Stack):: stack0
   type(IntegerDim1KindINT32Stack):: stack1
   type(IntegerDim2KindINT32Stack):: stack2
   Integer:: val0
   Integer, allocatable:: val1(:)
   Integer, allocatable:: val2(:, :)
   Logical:: isSuccess
   Integer:: i
   Integer, parameter:: N = 1000000

   ! dim = 0
   isSuccess = pop_stack(stack0, val0)
   TEST(.not.isSuccess)
   call push_stack(stack0, 1)
   call push_stack(stack0, 2)
   call push_stack(stack0, 3)
   call push_stack(stack0, 4)
   call push_stack(stack0, 5)
   isSuccess = pop_stack(stack0, val0)
   TEST(isSuccess)
   TEST(val0 == 5)
   isSuccess = pop_stack(stack0, val0)
   TEST(isSuccess)
   TEST(val0 == 4)
   isSuccess = pop_stack(stack0, val0)
   TEST(isSuccess)
   TEST(val0 == 3)
   isSuccess = pop_stack(stack0, val0)
   TEST(isSuccess)
   TEST(val0 == 2)
   isSuccess = pop_stack(stack0, val0)
   TEST(isSuccess)
   TEST(val0 == 1)
   isSuccess = pop_stack(stack0, val0)
   TEST(.not.isSuccess)
   isSuccess = pop_stack(stack0, val0)
   TEST(.not.isSuccess)

   ! dim = 0
   isSuccess = pop_stack(stack1, val1)
   TEST(.not.isSuccess)
   call push_stack(stack1, [1])
   call push_stack(stack1, [2])
   call push_stack(stack1, [3, 0, -3])
   call push_stack(stack1, [4])
   call push_stack(stack1, [5])
   isSuccess = pop_stack(stack1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [5]))
   isSuccess = pop_stack(stack1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [4]))
   isSuccess = pop_stack(stack1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [3, 0, -3]))
   isSuccess = pop_stack(stack1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [2]))
   isSuccess = pop_stack(stack1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [1]))
   isSuccess = pop_stack(stack1, val1)
   TEST(.not.isSuccess)
   isSuccess = pop_stack(stack1, val1)
   TEST(.not.isSuccess)

   ! dim 2
   call push_stack(stack2, reshape([1, 2, 3, 4, 5, 6], [2, 3]))
   call push_stack(stack2, reshape([1, 2, 3, 4, 5, 6, 7, 8], [4, 2]))
   isSuccess = pop_stack(stack2, val2)
   TEST(isSuccess)
   TEST(all(shape(val2) == [4, 2]))
   isSuccess = pop_stack(stack2, val2)
   TEST(isSuccess)
   TEST(all(shape(val2) == [2, 3]))

   ! Many times
   do i = 1, N
      call push_stack(stack0, i)
   end do
   do i = 1, N - 1
      isSuccess = pop_stack(stack0, val0)
   end do
   isSuccess = pop_stack(stack0, val0)
   TEST(isSuccess)
   TEST(val0 == 1)

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program stack_lib_test
