program test
  use mod1, only: func1, proc1
  use, non_intrinsic :: mod2, only: func2, CONST1
  use :: ISO_FORTRAN_ENV, only: OUTPUT_UNIT

  implicit none
  real:: a, b
  integer:: c, d
  integer, parameter:: VERSION = 1

  write(0, *) "input a, b: "         ! Try to read.
  write(6, *) "input a, b: "         ! Try to read.
  read(5, *) a, &
    & b
  stop
end program test
