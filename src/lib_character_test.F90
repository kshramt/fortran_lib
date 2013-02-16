#include "utils.h"
program lib_character_test
  USE_UTILS_H
  use, intrinsic:: iso_fortran_env, only: REAL64
  use lib_character, only: s, str
  use lib_character, only: operator(+), operator(*)

  implicit none

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
  TEST(str(0.0) == '0.0000000')
  TEST(str(1.0) == '1.0000000')
  TEST(str(0.0_REAL64) == '0.0000000000000000')
  TEST(str(-1.0_REAL64) == '-1.0000000000000000')
  TEST(str((1.0, -1.0)) == '(  1.0000000    , -1.0000000    )')
  TEST(str(.true.) == 'T')
  TEST(str(.false.) == 'F')

  ! +
  TEST('' + '' == '')
  TEST('' + 'a' == 'a')
  TEST('a' + '' == 'a')
  TEST('a' + 'b' == 'ab')
  TEST(' a ' + 'b' == ' a b')

  ! *
  TEST('a'*0 == '')
  TEST('a'*1 == 'a')
  TEST('a'*2 == 'aa')
  TEST('ab'*2 == 'abab')

  write(OUTPUT_UNIT, *) "SUCCESS: ", __FILE__
  stop
end program lib_character_test
