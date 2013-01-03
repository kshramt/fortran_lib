#ifndef UTILS_HAVE_ALREADY_LOADED
#  define UTILS_HAVE_ALREADY_LOADED
#  define USE_UTILS_H use, intrinsic:: iso_fortran_env, only: ERROR_UNIT, OUTPUT_UNIT
#  define WHERE_AM_I __FILE__, " ", __LINE__
#  ifdef __GFORTRAN__
#    define quote(x) "x"
#  else
#    ifdef __INTEL_COMPILER
#      define quote(x) #x
#    else
#      define quote(x) #x
#    endif
#  endif
#  define warn(message) write(ERROR_UNIT, *) "WARN: ", WHERE_AM_I, (message)
#  define raise(message) write(ERROR_UNIT, *) "RAISE: ", WHERE_AM_I, (message); stop 1
#  define ALL_OF(array, dim, index) index = lbound(array, dim), ubound(array, dim)
#  define has_val(array, val) (any((array) == (val)))
#  define is_iostat_bad(ios) (is_iostat_eor(ios) .or. is_iostat_end(ios))
#  define is_iostat_ok(ios) (.not.is_iostat_bad(ios))
#  define I (0, 1)

#  define warn_if(isBad) \
     if(isBad)then; \
       warn(quote(isBad)); \
     end if

#  define raise_if(isBad) \
     if(isBad)then; \
       raise(quote(isBad)); \
     end if
#  define assert(isOk) raise_if(.not.(isOk))
#  define test(isOk) \
     assert(isOk); \
     write(OUTPUT_UNIT, '(a)', advance = 'no') '.'

#  ifdef DEBUG
#    define debug_raise_if(isBad) raise_if(isBad)
#    define debug_print(x) write(ERROR_UNIT, *) "DEBUG: ", WHERE_AM_I, (x)
#    define debug_print_variable(x) write(ERROR_UNIT, *) "DEBUG: ", WHERE_AM_I, quote(x), (x)
#  else
#    define debug_raise_if(isBad)
#    define debug_print(x)
#    define debug_print_variable(x)
#  endif
#  define debug_assert(isOK) debug_raise_if(.not.(isOk))
#endif
