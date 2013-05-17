program test_lib_path
  use lib_path, only: dirname
  implicit none

  print*, dirname('/a/b/c.d')
  print*, dirname('/')
  print*, dirname('')

  stop
end program test_lib_path
