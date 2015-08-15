require 'fort'
LOG_2_CHAR_LEN_MAX = 10
REALS = ::Fort::Type::Real.multi_provide
INTEGERS = ::Fort::Type::Integer.multi_provide
LOGICALS = ::Fort::Type::Logical.multi_provide
COMPLEXES = ::Fort::Type::Complex.multi_provide
CHARACTERS = ::Fort::Type::Character.multi_provide(len: :':', len: [0]) # todo: `len: [0]` is only to avoid ICE
TYPES\
= REALS\
+ INTEGERS\
+ LOGICALS\
+ COMPLEXES\
+ CHARACTERS


def alloc?(t)
   t.dim > 0 || t.type == :Character
end


TYPES.each{|t|
  use_stmt = t.methods.include?(:kind) ? t.kind : ''
  puts "use, intrinsic:: iso_fortran_env, only: #{use_stmt}	#{t.to_s}	#{t.declare}	#{t.declare}#{alloc?(t) ? ', allocatable' : ''}"
}
