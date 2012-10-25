program test_lib_sort
  use lib_sort, only: qsort
  implicit none
  print*, qsort(huge(0.)*(/rand(), rand(), rand(), rand(), rand(), rand(), rand(), rand(), rand(), rand(), rand(), rand(), rand()/))
  stop
end program test_lib_sort
