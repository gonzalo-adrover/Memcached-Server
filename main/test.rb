require 'pp'

class Test

      attr_accessor :data_hash

      def initialize
            @data_hash = Hash.new
      end

      def storex(line)
            now = Time.now
            time = now + line
            data_hash.store('Time',time)
      end
      
      x = gets
      self.storex(x)
      puts(data_hash)
      #my_hash = {}
      #my_hash[:my_key] = 'value'
      #puts my_hash.has_key?("my_key".to_sym)
end