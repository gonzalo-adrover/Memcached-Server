class Command
 
      attr_accessor :key, :flag, :time, :bytes, :value, :cas_value

      def initialize(key, flag, expTime, bytes, value, cas_value)
          @key = key
          @flag = flag
          @expTime = expTime
          @bytes = bytes
          @value = value
          @cas_value = cas_value
      end

end
