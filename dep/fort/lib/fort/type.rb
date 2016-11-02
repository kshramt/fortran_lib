module ::Fort::Type
  USE_ISO_FORTRAN_ENV = "use, intrinsic:: iso_fortran_env, only: int8, int16, int32, int64, real32, real64, real128"
  DIM_RANGE = (0..7)

  module Providable
    ID_GENERATOR = lambda{
      id_number = '0'
      lambda{'T' + id_number.next!}}.call

    def provide(params = {})
      @params_default ||= {}
      @memo ||= {}
      params_for_new = @params_default.merge(params)
      @memo[params_for_new] ||= new(::Fort::Type::Providable::ID_GENERATOR.call, params_for_new)
    end

    # @param [Hash<Array>] params
    def multi_provide(params = {})
      @params_default_for_multi_provide ||= {}
      params_for_new = @params_default_for_multi_provide.merge(params)
      product_all(params_for_new.values.map{|val| Array(val)})\
        .map{|values| Hash[params_for_new.keys.zip(values)]}\
        .map{|hash| provide(hash)}
    end

    private

    def product_all(array)
      return array if array.empty?
      return array.first.map{|val| Array(val)} if array.one?
      first = array.first
      rest = array[1..-1]
      first.product(*rest)
    end
  end

  class Base
    extend Providable

    def initialize(id, params = {})
      @id = id
      @dim = params.fetch(:dim)
      raise ArgumentError, "@dim: #{@dim}" if @dim < 0
      @type = self.class.to_s.split('::').last.to_sym
    end
    attr_reader :id, :dim, :type

    def to_s
      "#{@type}Dim#{@dim}"
    end

    def declare
      "#{@type}#{dimension()}"
    end

    def parenthesis
      if @dim >= 1
        "(" + colons() + ")"
      else
        ''
      end
    end

    def dimension
      if @dim >= 1
        ", dimension" + parenthesis()
      else
        ''
      end
    end

    private

    def colons
      if @dim >= 1
        ([':']*@dim).join(', ')
      end
    end
  end

  class Numeric < Base
    def initialize(id, params = {})
      super
      @kind = params.fetch(:kind)
    end
    attr_reader :kind

    def to_s
      super + "Kind#{@kind}"
    end

    def declare
      "#{@type}(kind=#{@kind})#{dimension()}"
    end
  end

  class Integer < Numeric
    KINDS = [:int8, :int16, :int32, :int64]
    @params_default = {dim: 0, kind: :int32}
    @params_default_for_multi_provide = {dim: ::Fort::Type::DIM_RANGE, kind: KINDS}
  end

  class Real < Numeric
    KINDS = [:real32, :real64, :real128]
    @params_default = {dim: 0, kind: :real32}
    @params_default_for_multi_provide = {dim: ::Fort::Type::DIM_RANGE, kind: KINDS}
  end

  class Complex < Numeric
    KINDS = [:real32, :real64, :real128]
    @params_default = {dim: 0, kind: :real32}
    @params_default_for_multi_provide = {dim: ::Fort::Type::DIM_RANGE, kind: KINDS}
  end

  class Character < Base
    @params_default = {dim: 0, len: :*}
    @params_default_for_multi_provide = {dim: ::Fort::Type::DIM_RANGE, len: :*}

    def initialize(id, params)
      super
      @len = params.fetch(:len)
    end
    attr_reader :len

    def to_s
      super + "Len#{len_str()}"
    end

    def declare
      "#{@type}(len=#{@len})#{dimension()}"
    end

    private

    def len_str
      if @len == :*
        'Asterisk'
      elsif @len == :':'
        'Colon'
      else
        @len
      end
    end
  end

  class Logical < Numeric
    KINDS = [:int8, :int16, :int32, :int64] # xxx: ok?
    @params_default = {dim: 0, kind: :int32}
    @params_default_for_multi_provide = {dim: ::Fort::Type::DIM_RANGE, kind: KINDS}
  end
end
