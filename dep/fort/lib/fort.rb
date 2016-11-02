module Fort
  require 'fort/version'
  MustNotHappen = Class.new(Exception)
  INTRINSIC_MODULES = [
                       :ieee_arithmetic,
                       :ieee_exceptions,
                       :ieee_features,
                       :iso_c_binding,
                       :iso_fortran_env]

  require 'fort/type'
  require 'fort/src'
end
