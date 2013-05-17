program path_lib_test
  use path_lib, only: dirname
  implicit none

  print*, dirname('/a/b/c.d')
  print*, dirname('/')
  print*, dirname('')

  stop
end program path_lib_test
