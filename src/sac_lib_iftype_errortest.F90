# include "utils.h"
program sac_lib_iftype_errortest
  USE_UTILS_H
  use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
  use:: sac_lib

  implicit none

  type(Sac):: wHead

  call set_iftype(wHead, 'anything other than enumerated values')

  write(OUTPUT_UNIT, *) 'FAIL: ', __FILE__

  stop
end program sac_lib_iftype_errortest
