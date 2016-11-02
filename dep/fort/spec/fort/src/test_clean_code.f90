program test
use mod1, only: func1, proc1
use, non_intrinsic :: mod2, only: func2, const1
use :: iso_fortran_env, only: output_unit
implicit none
real:: a, b
integer:: c, d
integer, parameter:: version = 1
write(0, *) ""
write(6, *) ""
read(5, *) a,  b
stop
end program test
