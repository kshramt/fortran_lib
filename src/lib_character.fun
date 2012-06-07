test_suite lib_character
test test_str
  assert_equal(trim(str(3)), '3')
  assert_equal(trim(str(-3)), '-3')
  assert_equal(trim(str(34)), '34')
  assert_equal(trim(str(.true.)), 'T')
  assert_equal(trim(str(.false.)), 'F')
  assert_true(len(trim(str(3.2))) > 0)
  write(0, *), trim(str(3.2))
  assert_true(len(trim(str(3.2d0))) > 0)
  write(0, *), trim(str(3.2d0))
  assert_true(len(trim(str((3.2, 4.2)))) > 0)
  write(0, *), trim(str((3.2, 4.2)))
  assert_true(len(trim(str((3.2d0, 4.2d0)))) > 0)
  write(0, *), trim(str((3.2d0, 4.2d0)))
end test
end test_suite
