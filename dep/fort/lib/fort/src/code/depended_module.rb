module Fort
  class Src
    class Code
      class DependedModule
        attr_reader :name, :intrinsic_mode

        def initialize(name, intrinsic_mode = nil)
          @name = name
          @intrinsic_mode = if intrinsic_mode.nil?
                              if ::Fort::INTRINSIC_MODULES.include?(name)
                                :both
                              else
                                :non_intrinsic
                              end
                            else
                              intrinsic_mode
                            end
          raise ArgumentError unless [:intrinsic, :non_intrinsic, :both].include?(@intrinsic_mode)
        end

        def ==(other)
          self.class == other.class\
          && @name == other.name\
          && @intrinsic_mode == other.intrinsic_mode
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
