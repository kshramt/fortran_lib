module lib_constant
  implicit none
  private
  public:: PI, DEG_TO_RAD, RAD_TO_DEG

  double precision, parameter:: PI = 4*atan(1.0d0)
  double precision, parameter:: DEG_TO_RAD = PI/180
  double precision, parameter:: RAD_TO_DEG = 180/PI
end module lib_constant
