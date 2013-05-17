module path_lib
   use, non_intrinsic:: character_lib, only: s

   implicit none

   private
   public:: dirname

   character, parameter:: SEPARATOR = '/'
contains

   function dirname(path) result(this)
      character(len = *), intent(in):: path
      character(len = len(s(path))):: this

      integer:: lastSeparatorLoc

      lastSeparatorLoc = scan(path, SEPARATOR, .true.)
      this = path(1:lastSeparatorLoc)
   end function dirname
end module path_lib
