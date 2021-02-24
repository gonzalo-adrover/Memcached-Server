require_relative 'command'
require 'pp'

class CommandDAO

    attr_accessor :data_hash

    def initialize
        @data_hash = Hash.new
    end

    def set(arrayInfo, value)
        full_key = Command.new(arrayInfo[1],arrayInfo[2],arrayInfo[3],arrayInfo[4],value)
        data_hash.store(arrayInfo[1],full_key)
        return "la puse"
    end

    def add(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            puts "belongs"
            return "Key already exists in hash"
        else
            full_key = Command.new(arrayInfo[1],arrayInfo[2],arrayInfo[3],arrayInfo[4],value)
            data_hash.store(key,value)
            return "STORED\r\n"
        end
    end

    def replace(arrayInfo, value)
        if(data_hash.key?(arrayInfo[0])) then
            full_key = Command.new(arrayInfo[1],arrayInfo[2],arrayInfo[3],arrayInfo[4],value)
            data_hash.store(key,full_key)
            return "KEY REPLACED\r\n"
        else
            return "KEY CANNOT BE REPLACED, AS IT DOES NOT BELONG TO HASH"
        end
    end

    def append(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            existing_key = data_hash[arrayInfo[1]]
            appended_value = existing_key.value + value 
            existing_key.value = appended_value
            bytes = arrayInfo[3]
            key.bytes = bytes + key.bytes
            return "VALUE APPENDED\r\n"
        else
            return "VALUE CANNOT BE APPENDED, AS KEY DOES NOT BELONG TO HASH"
        end
    end

    def prepend(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            existing_key = data_hash[arrayInfo[1]]
            appended_value = value + existing_key.value 
            existing_key.value = appended_value
            bytes = arrayInfo[3]
            key.bytes = bytes + key.bytes
            return "VALUE PREPENDED\r\n"
        else
            return "VALUE CANNOT BE PREPENDED, AS KEY DOES NOT BELONG TO HASH"
        end
    end

    def cas(arrayInfo, value)
        return nil
    end

    def get(key)
        if(data_hash.key?(key)) then
            return 'esta'
        else
            return 'no esta'
        end
    end
        
    def gets(key)
        return data_hash
    end

end
    