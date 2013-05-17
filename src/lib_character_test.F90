#include "utils.h"
program lib_character_test
  USE_UTILS_H
  use, intrinsic:: iso_fortran_env, only: REAL64
  use lib_character, only: s, str
  use lib_character, only: operator(+)

  implicit none

  Character(len = 8):: sBuffer

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
  TEST(str(0.0_REAL64) == '0.0000000000000000')
  TEST(str(-1.0_REAL64) == '-1.0000000000000000')
  TEST(str((1.0_REAL64, -1.0_REAL64)) == '(  1.0000000000000000     , -1.0000000000000000     )')
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
end program lib_character_test
