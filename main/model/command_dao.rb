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
        return "STORED\r\n"
    end

    def add(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            return "NOT_STORED\r\n"
        else
            full_key = Command.new(arrayInfo[1],arrayInfo[2],arrayInfo[3],arrayInfo[4],value)
            data_hash.store(arrayInfo[1],full_key)
            return "STORED\r\n"
        end
    end

    def replace(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            data_hash.delete arrayInfo[1]
            full_key = Command.new(arrayInfo[1],arrayInfo[2],arrayInfo[3],arrayInfo[4],value)
            data_hash.store(arrayInfo[1],full_key)
            return "STORED\r\n"
        else
            return "NOT_STORED\r\n"
        end
    end

    def append(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            existing_key = data_hash[arrayInfo[1]]
            appended_value = existing_key.value + value 
            existing_key.value = appended_value
   #         bytes = arrayInfo[3]
   #         key.bytes = bytes + key.bytes
            return "STORED\r\n"
        else
            return "NOT_STORED\r\n"
        end
    end

    def prepend(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            existing_key = data_hash[arrayInfo[1]]
            appended_value = value + existing_key.value 
            existing_key.value = appended_value
        #    bytes = arrayInfo[3]
        #    key.bytes = bytes + key.bytes
            return "STORED\r\n"
        else
            return "NOT_STORED\r\n"
        end
    end

    def cas(arrayInfo, value)
        if true
            "EXISTS\r\n"
        else
            "NOT_FOUND\r\n"
        end
    end

    def get(key_array)
        i = 1
        n = key_array.length
        output = ""
        until i == n do
            key = key_array[i]
            command = self.data_hash[key]
            i = i + 1
            if(data_hash.key?(key)) then
                output =  output + "VALUE #{command.key} #{command.flag} #{command.bytes}\r\n#{command.value}\r\n" 
            else
                output = output + " \r\n" #added for information to the client
            end
        end
        return output + "END\r\n"
    end

    def gets(key)
        return data_hash
    end

end
    