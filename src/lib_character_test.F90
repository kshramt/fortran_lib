#include "utils.h"
program lib_character_test
  USE_UTILS_H
  use, intrinsic:: iso_fortran_env, only: REAL64
  use lib_character, only: s, str
  use lib_character, only: operator(+), operator(*)

  implicit none

  ! s
  test(s('') == '')
  test(s('a') == 'a')
  test(s(' ') == '')
  test(s(' a') == 'a')
  test(s('a ') == 'a')
  test(s(' a ') == 'a')
  test(s(' a b ') == 'a b')

  ! str
  test(str('a') == 'a')
  test(str(0) == '0')
  test(str(-1) == '-1')
  test(str(0.0) == '0.00000000')
  test(str(1.0) == '1.00000000')
  test(str(0.0_REAL64) == '0.0000000000000000')
  test(str(-1.0_REAL64) == '-1.0000000000000000')
  test(str((1.0, -1.0)) == '(  1.00000000    , -1.00000000    )')
  test(str(.true.) == 'T')
  test(str(.false.) == 'F')

  ! +
  test('' + '' == '')
  test('' + 'a' == 'a')
  test('a' + '' == 'a')
  test('a' + 'b' == 'ab')
  test(' a ' + 'b' == ' a b')

  ! *
  test('a'*0 == '')
  test('a'*1 == 'a')
  test('a'*2 == 'aa')
  test('ab'*2 == 'abab')

  write(OUTPUT_UNIT, *) "SUCCESS: ", __FILE__
  stop
end program lib_character_test
