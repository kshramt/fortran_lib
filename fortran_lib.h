#ifndef _FORTRAN_LIB_H_
#  define _FORTRAN_LIB_H_
#  define USE_FORTRAN_LIB_H use, intrinsic:: iso_fortran_env, only: error_unit, output_unit
#  define WHERE_AM_I __FILE__, " ", __LINE__
#  ifdef __STDC__
#    define quote(x) #x
#  else
#    define quote(x) "x"
#  endif
#  define WARN(message) write(error_unit, *) "WARN: ", WHERE_AM_I, (message)
#  define ERROR(message) write(error_unit, *) "ERROR: ", WHERE_AM_I, (message); error stop
#  define ALL_OF(index, array, dim_) index = lbound(array, dim=dim_, kind=kind(index)), ubound(array, dim=dim_, kind=kind(index))
#  define ENSURE_DEALLOCATED(arr) if(allocated(arr)) deallocate(arr)
#  define CONCURRENT_ALL_OF(index, array, dim_) concurrent (index = lbound(array, dim=dim_, kind=kind(index)):ubound(array, dim=dim_, kind=kind(index)))
#  define has_val(array, val) (any((array) == (val)))
#  define is_iostat_ok(ios) (ios == 0)
#  define is_iostat_bad(ios) (.not.is_iostat_ok(ios))
#  define PRINT_(x) write(error_unit, *) "INFO: ", WHERE_AM_I, (x)
#  define PRINT_VARIABLE(x) write(error_unit, *) "INFO: ", WHERE_AM_I, quote(x), ": ", (x)
#  define WRITE_KEY_VALUE(io, value) write(io, *, delim='none') quote(value), ' ', value

#  define WARN_IF(isBad) \
     if(isBad)then; \
       WARN(quote(isBad)); \
     end if

#  define ERROR_IF(isBad) \
     if(isBad)then; \
       ERROR(quote(isBad)); \
     end if
#  define ASSERT(isOk) ERROR_IF(.not.(isOk))
#  define TEST(isOk) \
     ASSERT(isOk); \
     write(output_unit, '(a)', advance='no') '.'
#  define check_bound(index, array, dim_) \
     (lbound(array, dim_) <= index .and. index <= ubound(array, dim_))
#  define size64(x) size(x, kind=int64)

#  ifdef DEBUG
#    define DEBUG_WARN(message) WARN(message)
#    define DEBUG_ERROR_IF(isBad) ERROR_IF(isBad)
#    define DEBUG_PRINT(x) write(error_unit, *) "DEBUG: ", WHERE_AM_I, (x)
#    define DEBUG_PRINT_VARIABLE(x) write(error_unit, *) "DEBUG: ", WHERE_AM_I, quote(x), ": ", (x)
#    define PURE impure
#  else
#    define DEBUG_WARN(message)
#    define DEBUG_ERROR_IF(isBad)
#    define DEBUG_PRINT(x)
#    define DEBUG_PRINT_VARIABLE(x)
#    define PURE pure
#  endif
#  define DEBUG_ASSERT(isOk) DEBUG_ERROR_IF(.not.(isOk))
#endif
