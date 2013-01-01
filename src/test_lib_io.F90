program test_lib_io
  use lib_io, only: LIB_IO_VERSION => VERSION, write_array, read_array

  implicit none
  real, allocatable:: A(:, :)
  real, allocatable:: I(:)
  real:: d(1:2, 1:3)
  integer:: j, k

  print*, LIB_IO_VERSION
  call write_array('int.array', (/1,2,3,4,5/), "what am i?")
  call write_array('r_desc.array', reshape((/1.0, 2.0, 3.0, 4.0, 5.0, 6.0/), (/2, 3/)), "real with desc test.", "desc2 is also added.")
  d = reshape((/1.0, 2.0, 3.0, 4.0, 5.0, 6.0/), (/2, 3/))
  do j = 1, 2
    write(6, *) (d(j, k), k = 1, 3)
  end do
  call read_array('r_desc.array', A)
  print*, A
  print*, shape(A)

  call read_array('int.array', I)
  print*, I
  print*, shape(I)
  call read_array('int.array', A)
end program test_lib_io
