# include "utils.h"
program sac_lib_test
  USE_UTILS_H
  use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
  use:: sac_lib

  implicit none

  type(Sac):: w1, w2
  Real(kind = SAC_REAL_KIND), allocatable:: body(:)
  Logical:: isRaised

  ! = head
  ! == float
  TEST(.not.is_delta_defined(w1))
  call set_delta(w1, 0.1)
  TEST(is_delta_defined(w1))
  TEST(get_delta(w1) == 0.1)
  call set_delta(w1, FLOAT_UNDEFINED)
  TEST(.not.is_delta_defined(w1))
  ! == integer
  TEST(.not.is_npts_defined(w1))
  call set_npts(w1, 42)
  TEST(is_npts_defined(w1))
  TEST(get_npts(w1) == 42)
  call set_npts(w1, INTEGER_UNDEFINED)
  TEST(.not.is_npts_defined(w1))
  ! == enumerated
  TEST(.not.is_iftype_defined(w1))
  call set_iftype(w1, 'itime')
  TEST(is_iftype_defined(w1))
  TEST(get_iftype(w1) == 'itime')
  call set_iftype(w1, 'anything other than enumerated values', isRaised)
  TEST(isRaised)
  ! == logical
  call set_leven(w1, .true.)
  TEST(is_leven_defined(w1))
  TEST(get_leven(w1))
  call set_leven(w1, .false.)
  TEST(is_leven_defined(w1))
  TEST(.not.get_leven(w1))
  ! == long string
  TEST(.not.is_kstnm_defined(w1))
  call set_kstnm(w1, 'JMA/ERM')
  TEST(is_kstnm_defined(w1))
  TEST(get_kstnm(w1) == 'JMA/ERM')
  call set_kstnm(w1, STRING_UNDEFINED)
  TEST(.not.is_kstnm_defined(w1))
  call set_kstnm(w1, '0123456789abcdef')
  TEST(get_kstnm(w1) == '0123456789abcdef')
  call set_kstnm(w1, '0123456789abcdefg', isRaised)
  TEST(isRaised)
  ! == short string
  TEST(.not.is_kevnm_defined(w1))
  call set_kevnm(w1, 'japan')
  TEST(is_kevnm_defined(w1))
  TEST(get_kevnm(w1) == 'japan')
  call set_kevnm(w1, STRING_UNDEFINED)
  TEST(.not.is_kevnm_defined(w1))
  call set_kevnm(w1, '12345678')
  TEST(get_kevnm(w1) == '12345678')
  call set_kevnm(w1, '123456789', isRaised)
  TEST(isRaised)
  ! = body
  ! == itime
  ! call get_body(w1, body, isRaised)
  ! == ixy
  ! == iamph
  ! == irlim
  ! == ixyz
  ! = read
  ! = write
  call set_iftype(w2, 'itime')   ! required
  call set_delta(w2, 0.05)   ! required

  call set_body(w2, real([1, 2, 3, 4, 5, 6, 7])) ! npts should be larger than 5 (SAC's limitation).
  call write(w2, 'tmp.sac')
  call read(w2, 'tmp.sac')
  call get_body(w2, body)
  print*, body

  write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

  stop
end program sac_lib_test
