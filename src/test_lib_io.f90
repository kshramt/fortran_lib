program test_lib_io
  use lib_io, only: VERSION, ARRAY_EXT, META_EXT, write_array, read_array

  implicit none
  real, allocatable:: A(:, :)
  real, allocatable:: I(:)

  print*, VERSION, ARRAY_EXT, META_EXT
!  call write_array('int', (/1,2,3,4,5/), "what am i?")
!  call write_array('r_desc', reshape((/1.0, 2.0, 3.0, 4.0, 5.0, 6.0/), (/2, 3/)), "real with desc test.", "desc2 is also added.")
  call read_array('r_desc', A)
  print*, A
  print*, shape(A)

  call read_array('int', I)
  print*, I
  print*, shape(I)
  call read_array('int', A)
end program test_lib_io
