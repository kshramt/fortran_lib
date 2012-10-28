#ifndef UTILS_HAVE_ALREADY_LOADED
#  define UTILS_HAVE_ALREADY_LOADED
#  define USE_UTILS_H use iso_fortran_env, only: ERROR_UNIT
#  define WHERE_AM_I __FILE__, " ", __LINE__
#  define WARN(...) write(ERROR_UNIT, *) "WARN: ", WHERE_AM_I, ##__VA_ARGS__
#  define RAISE(...) write(ERROR_UNIT, *) "RAISE: ", WHERE_AM_I, ##__VA_ARGS__; stop 1
#  define MUST_NOT_HAPPEN RAISE('Must not happen.') /* Must not happen unless a compiler has bugs. */
#  define BUG RAISE('Bug.')			  /* Should not happen unless some programs have bugs. */
#  define ALL(array, index) index = lbound(array, 1), ubound(array, 1)
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
#    define DEBUG_PRINT(...) print*, WHERE_AM_I, ##__VA_ARGS__
#    define DEBUG_PRINT_VARIABLE(x) print*, WHERE_AM_I, #x, x /* Print a variable name and it's value. */
#  else
#    define DEBUG_PRINT(...)
#    define DEBUG_PRINT_VARIABLE(x)
#  endif
#endif
