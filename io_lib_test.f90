#include "fortran_lib.h"
program io_lib_test
   USE_FORTRAN_LIB_H
   use, intrinsic:: iso_fortran_env, only: input_unit, output_unit, error_unit, real64, int8
   use, non_intrinsic:: io_lib, io_lib_version => version
   use, non_intrinsic:: comparable_lib, only: almost_equal
   use, non_intrinsic:: character_lib, only: operator(+)

   implicit none

   Real(kind=real64), allocatable:: xs(:), xsOriginal(:)
   Integer(kind=int8), allocatable:: ns(:, :), nsOriginal(:, :)
   Integer:: io
   Character(len = len('readwrite') + 1):: action
   Character(len = 2**10):: form, fileMktemp, fileInquire
   Logical:: isNamed, isEqual
   type(ArrayMetaV3):: meta

   isEqual = get_column_format_string(.true., 0) == '()'
   TEST(isEqual)
   isEqual = get_column_format_string(.false., 1) == '(g0)'
   TEST(isEqual)
   isEqual = get_column_format_string(1, 2) == '(g0, *(" ", g0))'
   TEST(isEqual)
   isEqual = get_column_format_string(1, 3) == '(g0, *(" ", g0))'
   TEST(isEqual)
   isEqual = get_column_format_string((1.2, 2.3), 0) == '()'
   TEST(isEqual)
   isEqual = get_column_format_string((1.2, 2.3), 1) == '("(", g0, ", ", g0, ")")'
   TEST(isEqual)
   isEqual = get_column_format_string((1.2, 2.3), 2) == '("(", g0, ", ", g0, ")", *(" ", "(", g0, ", ", g0, ")"))'
   TEST(isEqual)
   isEqual = get_column_format_string((1.2, 2.3), 3) == '("(", g0, ", ", g0, ")", *(" ", "(", g0, ", ", g0, ")"))'
   TEST(isEqual)

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

   ! = load, dump
   ! == Real 1D
   xs = [1, 2, 3, 4, 5]
   xsOriginal = xs
   call dump(xs, 'xs.array', 'Real 1D test', 'Multiple descriptions.')
   TEST(all(almost_equal(xs, xsOriginal)))
   TEST(load_version('xs.array') == io_lib_version)
   call load_meta_v_3(meta, 'xs.array')
   TEST(meta%type_ == 'Real')
   TEST(meta%kind_ == real64)
   TEST(meta%dim == 1)
   TEST(all(meta%sizes == shape(xs)))
   call load(xs, 'xs.array')
   TEST(all(almost_equal(xs, xsOriginal)))

   ! == Integer 2D
   ns = reshape(int([1, 2, 3, 4, 5, 6], kind = kind(ns)), [2, 3])
   nsOriginal = ns
   call dump(ns, 'ns.array')
   TEST(all(almost_equal(ns, nsOriginal)))
   call load(ns, 'ns.array')
   TEST(all(almost_equal(ns, nsOriginal)))

   write (OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program io_lib_test
