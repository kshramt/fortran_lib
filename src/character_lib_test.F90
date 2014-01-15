#include "utils.h"
program character_lib_test
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: REAL64
   use, non_intrinsic:: character_lib

   implicit none

   Character(len = 8):: sBuffer
   Character(len = 17):: dBuffer

   ! replace
   TEST(replace('a', 'a', 'bc') == 'bc')
   TEST(replace('a_a', 'a', 'bc') == 'bc_bc')
   TEST(replace('abcdabcdab', 'ab', 'PQR') == 'PQRcdPQRcdPQR')
   TEST(replace('abcabca', 'a', '') == 'bcbc')

   ! s
   TEST(s('') == '')
   TEST(s('a') == 'a')
   TEST(s(' ') == '')
   TEST(s(' a') == 'a')
   TEST(s('a ') == 'a')
   TEST(s(' a ') == 'a')
   TEST(s(' a b ') == 'a b')

   ! str
   TEST(str('a') == 'a')
   TEST(str(0) == '0')
   TEST(str(-1) == '-1')
   sBuffer = str(0.0)
   TEST(sBuffer == '0.000000')
   sBuffer = str(1.0)
   TEST(sBuffer == '1.000000')
   dBuffer = str(0.0_REAL64)
   TEST(dBuffer == '0.000000000000000')
   dBuffer = str(-1.0_REAL64)
   TEST(dBuffer == '-1.00000000000000')
   write(OUTPUT_UNIT, *) trim(str((1, 1)))
   TEST(str(.true.) == 'T')
   TEST(str(.false.) == 'F')

   ! +
   TEST('' + '' == '')
   TEST('' + 'a' == 'a')
   TEST('a' + '' == 'a')
   TEST('a' + 'b' == 'ab')
   TEST(' a ' + 'b' == ' a b')

   write(OUTPUT_UNIT, *) "SUCCESS: ", __FILE__
   stop
end program character_lib_test
