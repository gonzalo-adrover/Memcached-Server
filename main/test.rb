require 'pp'

class Test

      attr_accessor :data_hash

      def initialize
      @data_hash = Hash.new
      end

      data_hash = {:foo => 0, :bar => 1, :baz => 2}

      line = gets


      def getr(line)
            puts data_hash[:line]
      end
      
      
      #my_hash = {}
      #my_hash[:my_key] = 'value'
      #puts my_hash.has_key?("my_key".to_sym)
end