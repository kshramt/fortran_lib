# include "utils.h"
program sac_lib_test
  USE_UTILS_H
  use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
  use:: sac_lib

  implicit none

  type(Sac):: wHead, wBody, wIo
  Real(kind = SAC_REAL_KIND), allocatable:: body(:)

  ! = head
  ! == float
  TEST(.not.is_delta_defined(wHead))
  call set_delta(wHead, 0.1)
  TEST(is_delta_defined(wHead))
  TEST(get_delta(wHead) == 0.1)
  call set_delta(wHead, FLOAT_UNDEFINED)
  TEST(.not.is_delta_defined(wHead))
  ! == integer
  TEST(.not.is_npts_defined(wHead))
  call set_npts(wHead, 42)
  TEST(is_npts_defined(wHead))
  TEST(get_npts(wHead) == 42)
  call set_npts(wHead, INTEGER_UNDEFINED)
  TEST(.not.is_npts_defined(wHead))
  ! == enumerated
  TEST(.not.is_iftype_defined(wHead))
  call set_iftype(wHead, 'itime')
  TEST(is_iftype_defined(wHead))
  TEST(get_iftype(wHead) == 'itime')
  ! == logical
  call set_leven(wHead, .true.)
  TEST(is_leven_defined(wHead))
  TEST(get_leven(wHead))
  call set_leven(wHead, .false.)
  TEST(is_leven_defined(wHead))
  TEST(.not.get_leven(wHead))
  ! == long string
  TEST(.not.is_kstnm_defined(wHead))
  call set_kstnm(wHead, 'JMA/ERM')
  TEST(is_kstnm_defined(wHead))
  TEST(get_kstnm(wHead) == 'JMA/ERM')
  call set_kstnm(wHead, STRING_UNDEFINED)
  TEST(.not.is_kstnm_defined(wHead))
  call set_kstnm(wHead, '0123456789abcdef')
  TEST(get_kstnm(wHead) == '0123456789abcdef')
  ! == short string
  TEST(.not.is_kevnm_defined(wHead))
  call set_kevnm(wHead, 'japan')
  TEST(is_kevnm_defined(wHead))
  TEST(get_kevnm(wHead) == 'japan')
  call set_kevnm(wHead, STRING_UNDEFINED)
  TEST(.not.is_kevnm_defined(wHead))
  call set_kevnm(wHead, '12345678')
  TEST(get_kevnm(wHead) == '12345678')
  ! = body
  ! == itime
  call set_delta(wBody, 0.5)
  call set_body_itime(wBody, real([1, 2, 3, 4, 5, 6], kind = SAC_REAL_KIND))
  ! set_body, set_body_itime, get_body, get_body_itime
  ! == ixy
  ! == iamph
  ! == irlim
  ! == ixyz
  ! = read
  ! = write
  call set_iftype(wIo, 'itime')   ! required
  call set_delta(wIo, 0.05)   ! required

  call set_body(wIo, real([1, 2, 3, 4, 5, 6, 7])) ! npts should be larger than 5 (SAC's limitation).
  call write_sac(wIo, 'tmp.sac')
  call read_sac(wIo, 'tmp.sac')
  call get_body(wIo, body)
  print*, body

  write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

  stop
end program sac_lib_test
