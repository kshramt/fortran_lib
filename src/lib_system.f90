module lib_system
  use lib_util, only: raise
  use lib_character, only: s
  implicit none
  private
  public:: mkdir_p

contains

  subroutine mkdir_p(path, exitStatus)
    character(len = *) path
    integer, intent(out), optional:: exitStatus
    integer:: exitStatus_
    call execute_command_line("mkdir -p " // s(path), exitstat = exitStatus_)

    if(present(exitStatus))then
      exitStatus = exitStatus_
    elseif(exitStatus_ /= 0)then
      call raise("Failed: mkdir -p ", s(path))
    end if
  end subroutine mkdir_p
end module lib_system
