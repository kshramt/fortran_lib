#include "utils.h"
program lib_list_test
  use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT

  use lib_list, only: IntegerDim0KindINT32List
  use lib_list, only: size, delete_at, insert_at, val_at, shift, unshift, push, pop, clear, swap, is_size_one, is_empty, array_from_list, equivalent
  use lib_list, only: operator(.val.), assignment(=)
  
  implicit none
  
  type(IntegerDim0KindINT32List):: emptyList, l, m
  Integer, allocatable:: a(:), b(:)
  Integer:: i

  ! is_empty, is_size_one
  test(size(emptyList) == 0)
  test(is_empty(emptyList))
  test(.not.is_size_one(emptyList))
  l = [1, 2]
  test(.not.is_size_one(l))
  test(.not.is_empty(l))
  l = [1]
  test(is_size_one(l))

  ! assignment(=)
  a = [1, 2, 3, 4, 5]
  l = a                         ! list  <- array
  b = l                         ! array <- list
  test(all(a == b))
  test(size(l) == size(a))
  m = l                         ! list  <- list
  test(equivalent(m, l))
  l = emptyList
  test(size(l) == 0)

  ! val_at
  l = [1, 2, 3, 4, 5]
  test(val_at(l, 1) == 1)
  test(val_at(l, 2) == 2)
  test(val_at(l, 3) == 3)
  test(val_at(l, 4) == 4)
  test((l.val.1) == 1)
  test((l.val.2) == 2)
  test((l.val.3) == 3)
  test((l.val.4) == 4)

  ! delete_at
  l = [1, 2, 3, 4]
  test(delete_at(l, 1) == 1)
  test(size(l) == 3)
  l = [1, 2, 3, 4]
  test(delete_at(l, 2) == 2)
  test(size(l) == 3)
  l = [1, 2, 3, 4]
  test(delete_at(l, 3) == 3)
  test(size(l) == 3)
  l = [1, 2, 3, 4]
  test(delete_at(l, 4) == 4)
  test(size(l) == 3)
  i = delete_at(l, 1)
  test(size(l) == 2)
  i = delete_at(l, 1)
  test(size(l) == 1)
  i = delete_at(l, 1)
  test(size(l) == 0)

  ! insert_at
  l = [1, 2, 3, 4]
  call insert_at(l, -1, 1)
  test(size(l) == 5)
  test((l.val.1) == -1)
  test((l.val.2) == 1)
  test((l.val.5) == 4)
  call insert_at(l, -2, 6)
  test(size(l) == 6)
  test((l.val.5) == 4)
  test((l.val.6) == -2)

  ! unshift, shift, push and pop
  l = emptyList
  call unshift(l, 1)
  test(size(l) == 1)
  test((l.val.1) == 1)
  l = emptyList
  call push(l, 1)
  test(size(l) == 1)
  test((l.val.1) == 1)
  call unshift(l, 2)
  call push(l, 3)
  test(all(array_from_list(l) == [2, 1, 3]))
  test(pop(l) == 3)
  test(shift(l) == 2)
  test(shift(l) == 1)
  test(is_empty(l))
  l = [1]
  test(pop(l) == 1)
  test(is_empty(l))

  ! swap
  l = [1, 2, 3]
  call swap(l, 1, 2)
  test(all(array_from_list(l) == [2, 1, 3]))
  l = [1, 2, 3]
  call swap(l, 3, 1)
  test(all(array_from_list(l) == [3, 2, 1]))
  l = [1, 2, 3]
  call swap(l, 2, 1)
  test(all(array_from_list(l) == [2, 1, 3]))
  l = [1, 2, 3]
  call swap(l, 1, 1)
  test(all(array_from_list(l) == [1, 2, 3]))
  l = [1, 2, 3]
  call swap(l, 2, 2)
  test(all(array_from_list(l) == [1, 2, 3]))
  l = [1, 2, 3]
  call swap(l, 3, 3)
  test(all(array_from_list(l) == [1, 2, 3]))

  ! clear
  l = [1, 2, 3]
  call clear(l)
  test(is_empty(l))
  call clear(l)
  call clear(l)
  test(is_empty(l))

  write (ERROR_UNIT, *) 'SUCCESS: ', __FILE__

  stop
end program lib_list_test
