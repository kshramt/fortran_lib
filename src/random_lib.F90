#include "utils.h"
module random_lib
   USE_UTILS_H
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT

   implicit none

   private
   public:: random_seed_by_time

   interface random_seed_by_time
      module procedure random_seed_by_time_no_ret
      module procedure random_seed_by_time_ret
   end interface random_seed_by_time

contains

   subroutine random_seed_by_time_no_ret()
      Integer, allocatable:: seeds(:)

      call random_seed_by_time(seeds)
   end subroutine random_seed_by_time_no_ret

   subroutine random_seed_by_time_ret(seeds)
      Integer, parameter:: nT = 8
      Integer:: t(1:nT)
      Integer:: nSeeds, iSeed
      Integer, allocatable, intent(out):: seeds(:)

      call date_and_time(values=t)
      t = t(nT:1:-1) ! ms, s, M, h, tz, d, m, y
      call random_seed(size=nSeeds)
      allocate(seeds(1:nSeeds))
      do iSeed = 1, nSeeds
         seeds(iSeed) = t(mod(iSeed + nT - 1, nT) + 1)
      end do
      call random_seed(put=seeds)
   end subroutine random_seed_by_time_ret
end module random_lib
