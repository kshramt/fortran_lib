#include "fortran_lib.h"
program stack_lib_test
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only:OUTPUT_UNIT
   use, non_intrinsic:: stack_lib

   implicit none

   type(StackIntegerDim0KindINT32):: stack0
   type(StackIntegerDim1KindINT32):: stack1
   type(StackIntegerDim2KindINT32):: stack2
   Integer:: val0
   Integer, allocatable:: val1(:)
   Integer, allocatable:: val2(:, :)
   Logical:: isSuccess
   Integer:: i
   Integer, parameter:: N = 1000000

   ! dim = 0
   TEST(size(stack0) == 0)
   isSuccess = pop(stack0, val0)
   TEST(.not.isSuccess)
   call add(stack0, 1)
   call add(stack0, 2)
   call add(stack0, 3)
   call add(stack0, 4)
   call add(stack0, 5)
   TEST(size(stack0) == 5)
   TEST(all(array_of(stack0) == [5, 4, 3, 2, 1]))
   isSuccess = pop(stack0, val0)
   TEST(isSuccess)
   TEST(size(stack0) == 4)
   TEST(val0 == 5)
   isSuccess = pop(stack0, val0)
   TEST(isSuccess)
   TEST(val0 == 4)
   isSuccess = pop(stack0, val0)
   TEST(isSuccess)
   TEST(val0 == 3)
   isSuccess = pop(stack0, val0)
   TEST(isSuccess)
   TEST(val0 == 2)
   isSuccess = pop(stack0, val0)
   TEST(isSuccess)
   TEST(val0 == 1)
   isSuccess = pop(stack0, val0)
   TEST(.not.isSuccess)
   isSuccess = pop(stack0, val0)
   TEST(.not.isSuccess)
   TEST(size(stack0) == 0)

   ! dim = 0
   TEST(size(stack1) == 0)
   isSuccess = pop(stack1, val1)
   TEST(.not.isSuccess)
   call add(stack1, [1])
   call add(stack1, [2])
   call add(stack1, [3, 0, -3])
   call add(stack1, [4])
   call add(stack1, [5])
   TEST(size(stack1) == 5)
   isSuccess = pop(stack1, val1)
   TEST(size(stack1) == 4)
   TEST(isSuccess)
   TEST(all(val1 == [5]))
   isSuccess = pop(stack1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [4]))
   isSuccess = pop(stack1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [3, 0, -3]))
   isSuccess = pop(stack1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [2]))
   isSuccess = pop(stack1, val1)
   TEST(isSuccess)
   TEST(all(val1 == [1]))
   isSuccess = pop(stack1, val1)
   TEST(.not.isSuccess)
   isSuccess = pop(stack1, val1)
   TEST(.not.isSuccess)
   TEST(size(stack0) == 0)

   ! dim 2
   call add(stack2, reshape([1, 2, 3, 4, 5, 6], [2, 3]))
   call add(stack2, reshape([1, 2, 3, 4, 5, 6, 7, 8], [4, 2]))
   isSuccess = pop(stack2, val2)
   TEST(isSuccess)
   TEST(all(shape(val2) == [4, 2]))
   isSuccess = pop(stack2, val2)
   TEST(isSuccess)
   TEST(all(shape(val2) == [2, 3]))

   ! Many times
   do i = 1, N
      call add(stack0, i)
   end do
   do i = 1, N - 1
      isSuccess = pop(stack0, val0)
   end do
   isSuccess = pop(stack0, val0)
   TEST(isSuccess)
   TEST(val0 == 1)

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program stack_lib_test
