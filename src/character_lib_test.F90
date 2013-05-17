#include "utils.h"
program character_lib_test
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: REAL64
   use, non_intrinsic:: character_lib

   implicit none

   Character(len = 8):: sBuffer
   Character(len = 17):: dBuffer

   ! s
   TEST(s('') == '')
   TEST(s('a') == 'a')
   TEST(s(' ') == '')
   TEST(s(' a') == 'a')
   TEST(s('a ') == 'a')
   TEST(s(' a ') == 'a')
   TEST(s(' a b ') == 'a b')

   ! str_fixed
   TEST(str_fixed('a') == 'a')
   TEST(str_fixed(0) == '0')
   TEST(str_fixed(-1) == '-1')
   sBuffer = str_fixed(0.0)
   TEST(sBuffer == '0.000000')
   sBuffer = str_fixed(1.0)
   TEST(sBuffer == '1.000000')
   dBuffer = str_fixed(0.0_REAL64)
   TEST(dBuffer == '0.000000000000000')
   dBuffer = str_fixed(-1.0_REAL64)
   TEST(dBuffer == '-1.00000000000000')
   write(OUTPUT_UNIT, *) trim(str_fixed((1, 1)))
   TEST(str_fixed(.true.) == 'T')
   TEST(str_fixed(.false.) == 'F')

   ! +
   TEST('' + '' == '')
   TEST('' + 'a' == 'a')
   TEST('a' + '' == 'a')
   TEST('a' + 'b' == 'ab')
   TEST(' a ' + 'b' == ' a b')

   write(OUTPUT_UNIT, *) "SUCCESS: ", __FILE__
   stop
end program character_lib_test
