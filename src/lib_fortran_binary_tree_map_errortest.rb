$dependencies << 'lib_fortran.o'
$compiler = ENV['MY_FORTRAN']

setup <<-EOS
# include "../utils.h"
program runner
  USE_UTILS_H
  use, non_intrinsic:: lib_fortran

  implicit none

  type(CharacterDim0Len1IntegerDim0KindINT32BinaryTreeMap):: treeMap
EOS

errortest 'add_too_long_key', "call add(treeMap, '||', -1)"

teardown <<-EOS
  stop
end program runner
EOS
