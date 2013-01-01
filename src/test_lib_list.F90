program test_lib_list
  use lib_list
  implicit none
  type(RealList):: list, listCopy
  print*, size(list)

  call new(list, 1.0)
  print*, list_to_array(list)

  call new(list, 1.0)
  call push(list, 2.0)
  call push(list, 3.0)
  print*, list_to_array(list)

  listCopy = list
  call delete(list)
  print*, list_to_array(listCopy)

  

  stop
end program test_lib_list
