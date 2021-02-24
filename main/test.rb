require 'pp'

h = {:foo => 0, :bar => 1, :baz => 2}

puts h.key?(("foo").to_sym)


#my_hash = {}
#my_hash[:my_key] = 'value'
#puts my_hash.has_key?("my_key".to_sym)
