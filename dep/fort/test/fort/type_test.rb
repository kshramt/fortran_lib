require 'test_helper'

class TypeTest < ::MiniTest::Unit::TestCase
  T = ::Fort::Type

  def test_different_ids_for_different_types
    assert(not(T::Real.provide(dim: 1, kind: :real32).id == T::Complex.provide(dim: 1, kind: :real32).id))
  end

  def test_different_ids_for_different_hashs
    assert(not(T::Real.provide(dim: 1, kind: :real32).id == T::Real.provide(dim: 1, kind: :real64).id))
    assert(not(T::Real.provide(dim: 1, kind: :real32).id == T::Real.provide(dim: 1, kind: :real32, dummy: :dummy).id))
  end

  def test_same_id_for_same_type_and_hash
    assert(T::Real.provide(dim: 1, kind: :real32).id == T::Real.provide(kind: :real32, dim: 1).id)
  end

  def test_base
    assert_equal('BaseDim3', T::Base.provide(dim: 3).to_s)
    assert_equal('Base, dimension(:, :, :)', T::Base.provide(dim: 3).declare)
  end

  def test_numeric
    t = T::Numeric.provide(dim: 0, kind: 1)
    assert_equal('NumericDim0Kind1', t.to_s)
    assert_equal('Numeric(kind=1)', t.declare)
  end

  def test_multi_provide
    assert_equal(8, T::Logical.multi_provide(dim: (0..7), kind: [1]).size)
    assert_equal(21, T::Numeric.multi_provide(dim: [1, 2, 3, 4, 5, 6, 7], kind: [:real32, :real64, :real128]).size)
  end

  def test_integer
    t = T::Integer.provide(dim: 7, kind: :int32)
    assert_equal('IntegerDim7Kindint32', t.to_s)
    assert_equal('Integer(kind=int32), dimension(:, :, :, :, :, :, :)', t.declare)
  end

  def test_real
    t = T::Real.provide(dim: 1, kind: :real128)
    assert_equal('RealDim1Kindreal128', t.to_s)
    assert_equal('Real(kind=real128), dimension(:)', t.declare)
  end

  def test_complex
    t = T::Complex.provide(dim: 1, kind: :real128)
    assert_equal('ComplexDim1Kindreal128', t.to_s)
    assert_equal('Complex(kind=real128), dimension(:)', t.declare)
  end

  def test_character
    t = T::Character.provide(dim: 1, len: 2)
    assert_equal('CharacterDim1Len2', t.to_s)
    assert_equal('Character(len=2), dimension(:)', t.declare)
  end

  def test_character_asterisk
    t = T::Character.provide(dim: 1, len: :*)
    assert_equal('CharacterDim1LenAsterisk', t.to_s)
    assert_equal('Character(len=*), dimension(:)', t.declare)
  end

  def test_character_colon
    t = T::Character.provide(dim: 1, len: :':')
    assert_equal('CharacterDim1LenColon', t.to_s)
    assert_equal('Character(len=:), dimension(:)', t.declare)
  end

  def test_logical
    t = T::Logical.provide(dim: 1)
    assert_equal('LogicalDim1Kindint32', t.to_s)
    assert_equal('Logical(kind=int32), dimension(:)', t.declare)
    t = T::Logical.provide(dim: 1, kind: :int8)
    assert_equal('LogicalDim1Kindint8', t.to_s)
    assert_equal('Logical(kind=int8), dimension(:)', t.declare)
  end
end
