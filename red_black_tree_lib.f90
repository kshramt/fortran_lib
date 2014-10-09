# define X_FROM_Y_LR(x, y, isLeft)\
if(isLeft)then;\
   x => y%left;\
else;\
   x => y%right;\
end if
# define X_LR_FROM_Y(x, y, isLeft)\
if(isLeft)then;\
   x%left => y;\
else;\
   x%right => y;\
end if


module red_black_tree_lib
   use, intrinsic:: iso_fortran_env, only: INT8
   use, non_intrinsic:: character_lib, only: str

   implicit none


   private
   public:: insert
   public:: get
   public:: show


   type, public:: IntIntRBTree
      type(IntIntRBNode), pointer:: root => null()
   end type IntIntRBTree


   type, public:: IntIntRBNode
      Integer:: key
      Integer:: val
      Logical(kind=INT8):: isRed = .true.
      type(IntIntRBNode), pointer:: parent => null()
      type(IntIntRBNode), pointer:: left => null()
      type(IntIntRBNode), pointer:: right => null()
   end type IntIntRBNode


contains


   subroutine insert(tree, key, val)
      type(IntIntRBTree), intent(inout):: tree
      Integer, intent(in):: key
      Integer, intent(in):: val
      type(IntIntRBNode), pointer:: me
      type(IntIntRBNode), pointer:: child
      Logical(kind=INT8):: isChildLeft

      if(associated(tree%root))then
         me => tree%root
         do
            if(me%key == key)then ! overwrite current value
               me%key = key ! for mutable value
               me%val = val
               exit
            else ! append a new node
               isChildLeft = key < me%key
               X_FROM_Y_LR(child, me, isChildLeft)
               if(associated(child))then ! descend
                  me => child
               else ! append a new node
                  call append(tree, me, child, isChildLeft, key, val)
                  exit
               end if
            end if
         end do
      else ! create root
         allocate(tree%root)
         tree%root%key = key
         tree%root%val = val
         tree%root%isRed = .false.
      end if
   end subroutine insert


   function get(tree, key, found) result(ret)
      type(IntIntRBTree), intent(in):: tree
      Integer, intent(in):: key
      Logical, intent(out):: found
      Integer:: ret
      type(IntIntRBNode), pointer:: me, child

      me => tree%root
      if(associated(me))then
         do
            if(me%key == key)then
               ret = me%val
               found = .true.
               exit
            else
               X_FROM_Y_LR(child, me, key < me%key)
               if(associated(child))then
                  me => child
               else
                  found = .false.
                  exit
               end if
            end if
         end do
      else
         found = .false.
      end if
   end function get


   subroutine show(unit, tree)
      Integer, intent(in):: unit
      type(IntIntRBTree), intent(in):: tree
      Integer:: id

      id = 0
      write(unit, *) 'digraph G{'
      write(unit, *) 'node [shape=box]'
      write(unit, *) 'graph [rankdir=UD]'
      call show_impl(unit, tree%root, id)
      write(unit, *) '}'
   end subroutine show


   recursive subroutine show_impl(unit, node, id)
      Integer, intent(in):: unit
      type(IntIntRBNode), pointer, intent(in):: node
      Integer, intent(inout):: id
      Integer:: id_orig

      id = id + 1
      id_orig = id
      write(unit, '(3a)', advance='no') 'n', str(id), '[color='
      if(associated(node))then
         if(node%isRed)then
            write(unit, *) '"#ff0000", '
         else
            write(unit, *) '"#000000", '
         end if
         write(unit, *) 'label="', str(node%key), ' ', str(node%val), '"]'
         write(unit, *) 'n', str(id_orig), ' -> ', 'n', str(id + 1)
         call show_impl(unit, node%left, id)
         write(unit, *) 'n', str(id_orig), ' -> ', 'n', str(id + 1)
         call show_impl(unit, node%right, id)
      else
         write(unit, *) '"#000000", label="*"]'
      end if
   end subroutine show_impl


   subroutine append(tree, me, child, isChildLeft, key, val)
      type(IntIntRBTree), intent(inout):: tree
      type(IntIntRBNode), pointer, intent(inout):: me, child
      Logical(kind=INT8), intent(in):: isChildLeft
      Integer, intent(in):: key, val
      type(IntIntRBNode), pointer:: grandparent
      type(IntIntRBNode), pointer:: parent
      type(IntIntRBNode), pointer:: brother
      Logical(kind=INT8):: isParentLeft

      allocate(child)
      child%key = key
      child%val = val
      child%parent => me
      X_LR_FROM_Y(me, child, isChildLeft)
      if(me%isRed)then
         parent => me%parent
         grandparent => parent%parent
         X_FROM_Y_LR(brother, parent, parent%key < key)
         if(associated(brother))then
            me%isRed = .false.
            brother%isRed = .false.
            if(associated(grandparent))then
               parent%isRed = .true.
               if(grandparent%isRed)then
                  isParentLeft = key < grandparent%key
                  if(isParentLeft .eqv. key < grandparent%parent%key)then
                     call rotate_single(tree, parent, isParentLeft)
                  else
                     call rotate_double(tree, parent, isParentLeft)
                  end if
               end if
            else ! increase black node
               parent%isRed = .false.
            end if
         else
            if(associated(grandparent))then
               X_LR_FROM_Y(grandparent, me, key < grandparent%key)
               me%parent => grandparent
            else
               tree%root => me
               me%parent => null()
            end if
            me%isRed = .false.
            parent%left => null()
            parent%right => null()
            X_LR_FROM_Y(me, parent, .not.isChildLeft)
            parent%parent => me
            parent%isRed = .true.
         end if
      end if
   end subroutine append


   subroutine rotate_double(tree, me, isMeLeft)
      type(IntIntRBTree), intent(inout):: tree
      type(IntIntRBNode), pointer, intent(inout):: me
      Logical(kind=INT8), intent(in):: isMeLeft
      type(IntIntRBNode), pointer:: grandparent, parent, parent_s_new_child

      parent => me%parent
      grandparent => me%parent
      X_LR_FROM_Y(grandparent, me, .not.isMeLeft)
      X_FROM_Y_LR(parent_s_new_child, me, .not.isMeLeft)
      X_LR_FROM_Y(parent, parent_s_new_child, isMeLeft)
      parent%parent => me
      X_LR_FROM_Y(me, parent, .not.isMeLeft)
      call rotate_single(tree, parent, .not.isMeLeft)
   end subroutine rotate_double


   subroutine rotate_single(tree, me, isMeLeft)
      type(IntIntRBTree), intent(inout):: tree
      type(IntIntRBNode), pointer, intent(inout):: me
      Logical(kind=INT8), intent(in):: isMeLeft
      type(IntIntRBNode), pointer:: brother, parent, grandparent, great_grandparent

      parent => me%parent
      grandparent => parent%parent
      great_grandparent => grandparent%parent
      if(associated(great_grandparent))then
         X_LR_FROM_Y(great_grandparent, parent, me%key < great_grandparent%key)
      else
         tree%root => parent
      end if
      parent%isRed = .false.
      grandparent%isRed = .true.
      parent%parent => great_grandparent
      grandparent%parent => parent
      X_FROM_Y_LR(brother, parent, .not.isMeLeft)
      X_LR_FROM_Y(grandparent, brother, isMeLeft)
      X_LR_FROM_Y(parent, grandparent, .not.isMeLeft)
   end subroutine rotate_single
end module red_black_tree_lib


program main
   use, intrinsic:: iso_fortran_env, only: INPUT_UNIT, OUTPUT_UNIT, ERROR_UNIT
   use, non_intrinsic:: red_black_tree_lib, only: IntIntRBTree
   use, non_intrinsic:: red_black_tree_lib, only: insert, get, show

   implicit none

   type(IntIntRBTree):: t
   Logical:: found

   call insert(t, 0, 0)
   call insert(t, -1, 1)
   call insert(t, -2, 2)
   call insert(t, 1, 1)
   call insert(t, 2, 2)
   call insert(t, 3, 3)
   call insert(t, -3, 3)
   call insert(t, 4, 4)
   call insert(t, -4, 4)
   print*, '//', get(t, 0, found)
   print*, '//', found
   print*, '//', get(t, -1, found)
   print*, '//', found
   print*, '//', get(t, -2, found)
   print*, '//', found
   print*, '//', get(t, 1, found)
   print*, '//', found
   print*, '//', get(t, 2, found)
   print*, '//', found
   call show(OUTPUT_UNIT, t)

   stop
end program main
