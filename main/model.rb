require_relative 'data_key'

class Model

=begin
Purge expired keys
=end

    def initialize
        @data_hash = Hash.new
    end

    def set(key, flag, expTime, bytes,value)
        full_key = DataKey.new(key,flag,expTime,bytes,value)
        data_hash.store(key,full_key)
        return "STORED\r\n"
    end

end
