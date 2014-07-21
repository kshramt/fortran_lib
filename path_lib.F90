module path_lib
   implicit none

   private
   public:: dirname

   character, parameter:: SEPARATOR = '/'
contains

   function dirname(path) result(this)
      character(len = *), intent(in):: path
      character(len = len_trim(path)):: this

      integer:: lastSeparatorLoc

      lastSeparatorLoc = scan(path, SEPARATOR, .true.)
      this = path(1:lastSeparatorLoc)
   end function dirname
end module path_lib
