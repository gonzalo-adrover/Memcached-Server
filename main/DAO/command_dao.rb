require_relative 'command'
require 'pp'

class CommandDAO

    FLAG_RANGE = (2**16)
    MAX_EXP_TIME = 2592000
    MAX_BYTES= 256

    attr_accessor :data_hash, :cas_value

    def initialize
        @data_hash = Hash.new
        @cas_value = 0
    end

    def set(arrayInfo, value)
        status = self.command_checker(arrayInfo,value)
        if(status.include?("success")) then
            if(self.command_checker(arrayInfo, value)) then
                self.cas_value += 1
                full_key = Command.new(arrayInfo[1],arrayInfo[2],arrayInfo[3],arrayInfo[4],value,cas_value)
                data_hash.store(arrayInfo[1],full_key)
                return "STORED\r\n"
            else
                return "NOT_STORED\r\n"
            end
        elsif (status.include?("CLIENT_ERROR"))
            return status
        else
            return status
        end
    end

    def add(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            return "NOT_STORED\r\n"
        else
            self.cas_value += 1
            full_key = Command.new(arrayInfo[1],arrayInfo[2],arrayInfo[3],arrayInfo[4],value,cas_value)
            data_hash.store(arrayInfo[1],full_key)
            return "STORED\r\n"
        end
    end

    def replace(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            self.cas_value += 1
            data_hash.delete arrayInfo[1]
            full_key = Command.new(arrayInfo[1],arrayInfo[2],arrayInfo[3],arrayInfo[4],value,cas_value)
            data_hash.store(arrayInfo[1],full_key)
            return "STORED\r\n"
        else
            return "NOT_STORED\r\n"
        end
    end

    def append(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            self.cas_value += 1
            existing_key = data_hash[arrayInfo[1]]
            appended_value = existing_key.value + value 
            existing_key.value = appended_value
            existing_key.cas_value = cas_value
            bytes = arrayInfo[3]
            existing_key.bytes = Integer(bytes) + Integer(existing_key.bytes)
            return "STORED\r\n"
        else
            return "NOT_STORED\r\n"
        end
    end

    def prepend(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            self.cas_value += 1
            existing_key = data_hash[arrayInfo[1]]
            appended_value = value + existing_key.value 
            existing_key.value = appended_value
            existing_key.cas_value = cas_value
            bytes = arrayInfo[3]
            existing_key.bytes = Integer(bytes) + Integer(existing_key.bytes)
            return "STORED\r\n"
        else
            return "NOT_STORED\r\n"
        end
    end

    def cas(arrayInfo, value)
        if(data_hash.key?(arrayInfo[1])) then
            existing_key = data_hash[arrayInfo[1]]
            if(Integer(existing_key.cas_value) == Integer(arrayInfo[5])) then
                self.set(arrayInfo, value)
            else    
                "EXISTS\r\n"
            end
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

    def gets(key_array)
        i = 1
        n = key_array.length
        output = ""
        until i == n do
            key = key_array[i]
            command = self.data_hash[key]
            i = i + 1
            if(data_hash.key?(key)) then
                output =  output + "VALUE #{command.key} #{command.flag} #{command.bytes} #{command.cas_value}\r\n#{command.value}\r\n" 
            else
                output = output + " \r\n" #added for information to the client
            end
        end
        return output + "END\r\n"
    end



    def command_checker (array,data)
        flag = array[2]
        expTime = array[3]
        bytes = array[4]
        valid_commands = ["set","add","repalce","append","prepend","cas","get","gets"]
        error = ""
        if(valid_commands.index(array[0])) then
            error = "CLIENT_ERROR"
            if(Integer(flag) > FLAG_RANGE || Integer(flag) < -FLAG_RANGE) then
                error = " - Inavlid flag"
            end 
            if (Integer(expTime) < 0 || Integer(expTime) > MAX_EXP_TIME) then
                error = error + " - Invalid expiration time"
            end
            if (Integer(bytes) < 0 || Integer(bytes) > MAX_BYTES) then
                error = error + " - Invalid bytes size"
            end
            if (Integer(bytes) != data.length) then
                error = error + " - Bytes and length of data block do not match"
            else
                error = "success"
            end
            return error + "\r\n"
        else 
            return error = "ERROR\r\n"
        end
    end

end
    