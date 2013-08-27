$dependencies << 'binary_tree_map_lib.o'
$compiler = ENV.fetch('MY_FORTRAN_DEBUG', 'gfortran -ffree-line-length-none -fmax-identifier-length=63 -pipe -cpp -C -Wall -fbounds-check -O0 -fbacktrace -ggdb -pg -DDEBUG')

setup <<-EOS
# include "../utils.h"
program runner
  USE_UTILS_H
  use, non_intrinsic:: binary_tree_map_lib

  implicit none

  type(CharacterDim0Len1IntegerDim0KindINT32BinaryTreeMap):: treeMap
EOS

errortest 'add too long key', "call append(treeMap, '||', -1)"

teardown <<-EOS
  stop
end program runner
EOS
