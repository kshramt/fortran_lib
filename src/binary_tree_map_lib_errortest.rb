$dependencies << 'lib_fortran.o'
$compiler = ENV['MY_FORTRAN']

setup <<-EOS
# include "../utils.h"
program runner
  USE_UTILS_H
  use, non_intrinsic:: binary_tree_map_lib

  implicit none

  type(CharacterDim0Len1IntegerDim0KindINT32BinaryTreeMap):: treeMap
EOS

errortest 'add too long key', "call add_binary_tree_map(treeMap, '||', -1)"

teardown <<-EOS
  stop
end program runner
EOS
