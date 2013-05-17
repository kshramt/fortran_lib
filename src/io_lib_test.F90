#include "utils.h"
program lib_io_test
  use, intrinsic:: iso_fortran_env, only: &
    INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT, &
    REAL64, INT8
  use lib_io
  use:: lib_comparable, only: equivalent
  use:: lib_character, only: operator(+)
  
  implicit none
  
  Real(kind = REAL64), allocatable:: xs(:), xsOriginal(:)
  Integer(kind = INT8), allocatable:: ns(:, :), nsOriginal(:, :)

  ! = read_array, write_array, number_of_lines
  ! == Real 1D
  xs = [1, 2, 3, 4, 5]
  xsOriginal = xs
  call write_array('xs.array', xs, 'Real 1D test', 'Multiple descriptions.')
  TEST(all(equivalent(xs, xsOriginal)))
  call read_array('xs.array', xs)
  TEST(all(equivalent(xs, xsOriginal)))

  ! == Integer 2D
  ns = reshape(int([1, 2, 3, 4, 5, 6], kind = kind(ns)), [2, 3])
  nsOriginal = ns
  call write_array('ns.array', ns)
  TEST(all(equivalent(ns, nsOriginal)))
  call read_array('ns.array', ns)
  TEST(all(equivalent(ns, nsOriginal)))

  write (OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__
  
  stop
end program lib_io_test
