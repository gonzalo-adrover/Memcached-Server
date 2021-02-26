class Command
 
      attr_accessor :key, :flag, :time, :bytes, :value

      def initialize(key, flag, expTime, bytes,value)
          @key = key
          @flag = flag
          @expTime = expTime
          @bytes = bytes
          @value = value
      end

end
