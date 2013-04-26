# include "utils.h"
program sac_lib_kstnm_errortest
  USE_UTILS_H
  use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
  use:: sac_lib

  implicit none

  type(Sac):: wHead

  call set_kstnm(wHead, '0123456789abcdefg')

  write(OUTPUT_UNIT, *) 'FAIL: ', __FILE__

  stop
end program sac_lib_kstnm_errortest
