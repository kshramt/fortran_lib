program test_lib_array
  use lib_array, only: turn_over
  use lib_io, only: write_array
  implicit none
  integer:: i, j, k
  real:: a(1:2, 1:3, 1:4) = reshape((/(i, i = 1, 24)/), (/2,3,4/))
  real:: b(1:4, 1:3, 1:2)
  do j = 1, 3
    print*, j
    do i = 1, 2
      write(6, *) (a(i, j, k), k = 1, 4)
    end do
  end do
  
  b = turn_over(a)
  do j = 1, 3
    print*, j
    do i = 1, 4
      write(6, *) (b(i, j, k), k = 1, 2)
    end do
  end do
  
  call write_array('normal', a)
  call write_array('turn_over', b)

  stop
end program test_lib_array
