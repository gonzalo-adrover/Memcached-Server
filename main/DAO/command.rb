class Command
 
      attr_accessor :key, :flag, :time, :bytes, :value, :cas_value, :exp_Time

      def initialize(key, flag, exp_Time, bytes, value, cas_value)
          @key = key
          @flag = flag
          @exp_Time = exp_Time
          @bytes = bytes
          @value = value
          @cas_value = cas_value
      end

end
