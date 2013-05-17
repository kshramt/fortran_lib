# include "utils.h"
program path_lib_test
   USE_UTILS_H
   use, non_intrinsic:: path_lib, only: dirname
   implicit none

   TEST(dirname('/a/b/c.d') == '/a/b/')
   TEST(dirname('/') == '/')
   TEST(dirname('') == '')

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program path_lib_test
