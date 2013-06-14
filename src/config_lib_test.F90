# include "utils.h"
program main
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, intrinsic:: iso_fortran_env, only: REAL128
   use:: config_lib

   implicit none

   Integer:: io
   Logical:: l
   Character(len=2**10):: str
   Integer:: nX
   Real:: lX
   Complex(kind=REAL128):: c

   open(newunit=io, file='config_lib_test.in', status='old', action='read')
   TEST(.not.get_config_value(io, 'no such key', l))
   TEST(get_config_value(io, 'logical1', l))
   TEST(l)
   TEST(get_config_value(io, 'logicaL1', l))
   TEST(.not.l)
   TEST(get_config_value(io, 'str', str))
   TEST(str == ' hop step jump')
   TEST(get_config_value(io, 'nX', nX))
   TEST(nX == 32)
   TEST(get_config_value(io, 'lX', lX))
   TEST(lX == 123.4)
   TEST(get_config_value(io, 'impedance', c))
   TEST(c == (1, 2))
   close(io)

   write(OUTPUT_UNIT, *) 'SUCCESS: ', __FILE__

   stop
end program main
