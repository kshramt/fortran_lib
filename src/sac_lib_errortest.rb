$dependencies << 'character_lib.o'
$dependencies << 'sac_lib.o'
$compiler = ENV['MY_FORTRAN_DEBUG']

setup <<-EOS
# include "../utils.h"
program runner
  USE_UTILS_H
  use, non_intrinsic:: sac_lib

  implicit none

  type(Sac):: wHead
  Character:: cTrash
  Integer:: iTrash
EOS

errortest 'set_kstnm with too long argument', "call set_kstnm(wHead, '0123456789abcdefg')"
errortest 'set_kevnm with too long argument', "call set_kevnm(wHead, '123456789')"
errortest 'set_iftype with invalid argument', "call set_iftype(wHead, 'anything other than enumerated values')"

errortest 'get_iftype for undefined value', "cTrash = get_iftype(wHead)"
errortest 'get_imagsrc for undefined value', "cTrash = get_imagsrc(wHead)"

teardown <<-EOS
  stop
end program runner
EOS
