module lib_constant
  use iso_fortran_env, only: REAL32, REAL64
  implicit none
  private
  public:: PI, DEG_TO_RAD, RAD_TO_DEG
  real(REAL64), parameter:: PI = 4*atan(1.0d0)
  real(REAL64), parameter:: DEG_TO_RAD = PI/180
  real(REAL64), parameter:: RAD_TO_DEG = 180/PI

end module lib_constant
