module lib_constant
  use iso_fortran_env, only: REAL32, REAL64

  implicit none

  private

  public:: PI, DEG_TO_RAD, RAD_TO_DEG
  public:: get_nan, get_infinity

  real(REAL64), parameter:: PI = 4*atan(1.0d0)
  real(REAL64), parameter:: DEG_TO_RAD = PI/180
  real(REAL64), parameter:: RAD_TO_DEG = 180/PI

contains

  elemental function get_nan() result(this)
    real(REAL32):: this

    character(len = len('NaN')):: buf ! buf can not be a parameter.

    buf = 'NaN'
    read(buf, *) this
  end function get_nan

  elemental function get_infinity() result(this)
    real(REAL32):: this

    character(len = len('Infinity')):: buf ! buf can not be a parameter.

    buf = 'Infinity'
    read(buf, *) this
  end function get_infinity
end module lib_constant
