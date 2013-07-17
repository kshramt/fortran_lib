#include "utils.h"
program io_lib_test
   use, intrinsic:: iso_fortran_env, only: &
      INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT, &
      REAL64, INT8
   use, non_intrinsic:: io_lib, IO_LIB_VERSION => VERSION
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: character_lib, only: operator(+)
   
   implicit none
   
   Real(kind = REAL64), allocatable:: xs(:), xsOriginal(:)
   Integer(kind = INT8), allocatable:: ns(:, :), nsOriginal(:, :)
   Integer:: io
   Character(len = len('readwrite') + 1):: action
   Character(len = 2**10):: form, fileMktemp, fileInquire
   Logical:: isNamed
   type(ArrayMeta):: meta

   TEST(len(get_column_format_string(1.0, 1)) == len('(1(1x, g13.6))'))
   TEST(len(get_column_format_string(1.0, 2)) == len('(2(1x, g13.6))'))
   TEST(len(get_column_format_string(1.0, 10)) == len('(10(1x, g13.6))'))
   TEST(get_column_format_string(1.0, 1) == '(1(1x, g13.6))')
   TEST(get_column_format_string(1.0, 2) == '(2(1x, g13.6))')
   TEST(get_column_format_string(1.0, 10) == '(10(1x, g13.6))')

   call mktemp(io)
   inquire(io, action = action, named = isNamed, form = form)
   TEST(action == 'READWRITE')
   TEST(form == 'FORMATTED')
   TEST(isNamed)
   close(io)

   call mktemp(io, form = 'unformatted', file = fileMktemp)
   inquire(io, action = action, name = fileInquire, form = form, named = isNamed)
   TEST(form == 'UNFORMATTED')
   TEST(action == 'READWRITE')
   TEST(fileMktemp == fileInquire)
   TEST(isNamed)
   close(io)

   ! = read_array, write_array
   ! == Real 1D
   xs = [1, 2, 3, 4, 5]
   xsOriginal = xs
   call write_array(xs, 'xs.array', 'Real 1D test', 'Multiple descriptions.')
   TEST(all(almost_equal(xs, xsOriginal)))
   TEST(read_array_version('xs.array') == IO_LIB_VERSION)
   call read_array_meta(meta, 'xs.array')
   TEST(meta%dataType == 'RealDim1KindREAL64')
   TEST(meta%dim == 1)
   TEST(all(meta%sizes == shape(xs)))
   call read_array(xs, 'xs.array')
   TEST(all(almost_equal(xs, xsOriginal)))

   ! == Integer 2D
   ns = reshape(int([1, 2, 3, 4, 5, 6], kind = kind(ns)), [2, 3])
   nsOriginal = ns
   call write_array(ns, 'ns.array')
   TEST(all(almost_equal(ns, nsOriginal)))
   call read_array(ns, 'ns.array')
   TEST(all(almost_equal(ns, nsOriginal)))

   write (OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__
   
   stop
end program io_lib_test
