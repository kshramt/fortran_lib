program test_lib_character
  use lib_character, only: s, str, STR_LEN
  implicit none
  print*, STR_LEN
  print*, '|' // str(huge(3.0d0)) // '|'
  print*, '|' // str(3) // '|'
  print*, '|' // str(-3) // '|'
  print*, '|' // str(3.0) // '|'
  print*, '|' // str((3.0, 4.0)) // '|'
  print*, '|' // str((3.0, 4.0d0)) // '|'
  print*, '|' // str(.true.) // '|'
  print*, '|' // str(.false.) // '|'
  print*, '|' // s(" abc d  ") // '|'
  stop
end program test_lib_character
