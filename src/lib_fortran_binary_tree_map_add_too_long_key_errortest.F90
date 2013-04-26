program lib_fortran_binary_tree_map_add_too_long_key_errortest
  use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
  use:: lib_fortran
  
  implicit none
  
  type(CharacterDim0Len1IntegerDim0KindINT32BinaryTreeMap):: treeMap

  call add(treeMap, '||', -1)
  
  write(OUTPUT_UNIT, *) 'FAIL: ', __FILE__
  
  stop
end program lib_fortran_binary_tree_map_add_too_long_key_errortest
