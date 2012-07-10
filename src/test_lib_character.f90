program test_lib_character
  use lib_character, only: str, STR_LEN
  implicit none
  character(len = STR_LEN):: buf
  buf = trim(str(huge(3.0d0)))
  print*, trim(buf)
  print*, trim(str(3))
  print*, trim(str(-3))
  print*, trim(str(3.0))
  print*, trim(str((3.0, 4.0)))
  print*, trim(str((3.0, 4.0d0)))
  print*, trim(str(.true.))
  print*, trim(str(.false.))
  print*, '@' // s(" abc d  ") // '@'
  stop
end program test_lib_character
