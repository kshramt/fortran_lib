module Fort
  class Src
    class Code
      class ProgramUnit
        attr_reader :type, :name
        attr_accessor :deps

        def initialize(name, type, deps = [])
          raise ArgumentError unless [:program, :module].include?(type)

          @name = name
          @type = type
          @deps = deps
        end

        def ==(other)
          self.class == other.class\
          && @name == other.name\
          && @type == other.type\
          && @deps == other.deps
        end

        def eql?(other)
          self.class == other.class && self.hash == other.hash
        end

        def hash
          [@name, @intrinsic_mode].hash
        end
      end
    end
  end
end
