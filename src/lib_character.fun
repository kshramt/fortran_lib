test_suite lib_character
  integer, parameter:: iOne = 1, iMinusOne = -1
  integer(8), parameter:: i8One = 1, i8MinusOne = -1
  logical, parameter:: true = .true., false = .false.
  real, parameter:: rOne = 1.0, rMinusOne = -1.0
  real:: rWork
  double precision, parameter:: dOne = 1.0d0, dMinusOne = -1.0d0
  double precision:: dWork
  complex, parameter:: cOneOne = (rOne, rOne)
  complex:: cWork
  complex(kind(0.0d0)), parameter:: dcOneOne = (dOne, dOne)
  complex(kind(0.0d0)):: dcWork
  character(len = 2048):: buf

test test_str_len
  assert_equal(STR_LEN, len(str(0)))
end test

test test_str_integeer
  print*, __FILE__, __LINE__, trim(str(iOne))
  assert_equal(trim(str(iOne)), '1')

  print*, __FILE__, __LINE__, trim(str(iMinusOne))
  assert_equal(trim(str(iMinusOne)), '-1')
end test

test test_str_integer_8_
  print*, __FILE__, __LINE__, trim(str(i8One))
  assert_equal(trim(str(i8One)), '1')

  print*, __FILE__, __LINE__, trim(str(i8MinusOne))
  assert_equal(trim(str(i8MinusOne)), '-1')
end test


test test_str_logical
  print*, __FILE__, __LINE__, trim(str(true))
  assert_equal(trim(str(true)), 'T')

  print*, __FILE__, __LINE__, trim(str(false))
  assert_equal(trim(str(.false.)), 'F')
end test

test test_str_real
  buf = trim(str(rOne))
  print*, __FILE__, __LINE__, trim(buf)
  read(buf, *) rWork
  assert_real_equal(rOne, rWork)

  buf = trim(str(rMinusOne))
  print*, __FILE__, __LINE__, trim(buf)
  read(buf, *) rWork
  assert_real_equal(rMinusOne, rWork)
end test

test test_str_double_precision
  buf = trim(str(dOne))
  print*, __FILE__, __LINE__, trim(buf)
  read(buf, *) dWork
  assert_real_equal(dOne, dWork)

  buf = trim(str(dMinusOne))
  print*, __FILE__, __LINE__, trim(buf)
  read(buf, *) dWork
  assert_real_equal(dMinusOne, dWork)
end test

test test_str_complex
  buf = trim(str(cOneOne))
  print*, __FILE__, __LINE__, trim(buf)
  read(buf, *) cWork
  assert_real_equal(real(cOneOne), real(cWork))
  assert_real_equal(aimag(cOneOne), aimag(cWork))
end test

test test_str_complex_kind_0_0d0__
  buf = trim(str(dcOneOne))
  print*, __FILE__, __LINE__, trim(buf)
  read(buf, *) dcWork
  assert_real_equal(real(dcOneOne), real(dcWork))
  assert_real_equal(aimag(dcOneOne), aimag(dcWork))
end test
end test_suite
