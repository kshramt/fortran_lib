#ifndef UTILS_HAVE_ALREADY_LOADED
#  define UTILS_HAVE_ALREADY_LOADED
#  define USE_UTILS_H use, intrinsic:: iso_fortran_env, only: ERROR_UNIT, is_iostat_eor, is_iostat_end
#  define WHERE_AM_I __FILE__, " ", __LINE__
#  define WARN(...) write(ERROR_UNIT, *) "WARN: ", WHERE_AM_I, ##__VA_ARGS__
#  define RAISE(...) write(ERROR_UNIT, *) "RAISE: ", WHERE_AM_I, ##__VA_ARGS__; stop 1
#  define MUST_NOT_HAPPEN RAISE('Must not happen.') /* Must not happen unless a compiler has bugs. */
#  define BUG RAISE('Bug.')			  /* Should not happen unless some programs have bugs. */
#  define ALL_OF(array, dim, index) index = lbound(array, dim), ubound(array, dim)
#  define HAS_VAL(array, val) any(array == val)
#  define IS_IOSTAT_BAD(ios) (is_iostat_eor(ios) .or. is_iostat_end(ios))
#  define IS_IOSTAT_OK(ios) (.not.IS_IOSTAT_BAD(ios))
#  define I (0, 1)

#  define WARN_IF(isBad, ...) \
     if(isBad)then; \
       WARN(#isBad, " ", ##__VA_ARGS__); \
     end if

#  define RAISE_IF(isBad, ...) \
     if(isBad)then; \
       RAISE(#isBad, " ", ##__VA_ARGS__); \
     end if

#  ifdef DEBUG
#    define DEBUG_RAISE_IF(isBad, ...) RAISE_IF(isBad, ##__VA_ARGS__)
#    define DEBUG_PRINT(...) write(ERROR_UNIT, *) "DEBUG: ", WHERE_AM_I, ##__VA_ARGS__
#    define DEBUG_PRINT_VARIABLE(x) write(ERROR_UNIT, *) "DEBUG: ", WHERE_AM_I, #x, x /* Print a variable name and it's value. */
#  else
#    define DEBUG_PRINT(...)
#    define DEBUG_PRINT_VARIABLE(x)
#    define DEBUG_RAISE_IF(isBad, ...)
#  endif
#endif
