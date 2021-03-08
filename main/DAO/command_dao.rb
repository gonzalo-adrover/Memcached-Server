require_relative 'command'
require_relative '../message'
require_relative '../validator'
require 'pp'

class CommandDAO

    attr_accessor :data_hash, :cas_value, :validator

    def initialize
        @data_hash = Hash.new
        @validator = Validator.new
        @cas_value = 1
    end

    def set(arrayInfo, value)
        validator.remove_expired(data_hash)
        status = validator.command_checker_storage(arrayInfo,value)
        if(status.include?(SUCCESS)) then
                exp_time = Time.now + Integer(arrayInfo[3])
                if arrayInfo.length == 5 then
                    full_key = Command.new(arrayInfo[1],Integer(arrayInfo[2]),exp_time,Integer(arrayInfo[4]),value,cas_value)
                elsif arrayInfo.length == 6 then
                    full_key = Command.new(arrayInfo[1],Integer(arrayInfo[2]),exp_time,Integer(arrayInfo[4]),value,Integer(arrayInfo[5]))
                end
                data_hash.store(arrayInfo[1],full_key)
                return STORED
        elsif (status.include?(CLIENT_ERROR))
            return status
        else
            return status
        end
    end

    def add(arrayInfo, value)
        validator.remove_expired(data_hash)
        status = validator.command_checker_storage(arrayInfo,value)
        if(status.include?(SUCCESS)) then
           if(!data_hash.key?(arrayInfo[1])) then
                exp_time = Time.now + Integer(arrayInfo[3])
                full_key = Command.new(arrayInfo[1],Integer(arrayInfo[2]),exp_time,Integer(arrayInfo[4]),value,cas_value)
                data_hash.store(arrayInfo[1],full_key)
                return STORED
            else
                return NOT_STORED
            end
        elsif (status.include?(CLIENT_ERROR))
            return status
        else
            return status
        end
    end

    def replace(arrayInfo, value)
        validator.remove_expired(data_hash)
        status = validator.command_checker_storage(arrayInfo,value)
        if(status.include?(SUCCESS)) then
            if(data_hash.key?(arrayInfo[1])) then
                existing_key = data_hash[arrayInfo[1]]
                existing_key.cas_value += 1
                exp_time = Time.now + Integer(arrayInfo[3])
                data_hash.delete arrayInfo[1]
                full_key = Command.new(arrayInfo[1],Integer(arrayInfo[2]),exp_time,Integer(arrayInfo[4]),value,existing_key.cas_value)
                data_hash.store(arrayInfo[1],full_key)
                return STORED
            else
                return NOT_STORED
            end
        elsif (status.include?(CLIENT_ERROR))
            return status
        else
            return status
        end
    end

    def append(arrayInfo, value)
        validator.remove_expired(data_hash)
        status = validator.command_checker_storage(arrayInfo,value)
        if(status.include?(SUCCESS)) then
            if(data_hash.key?(arrayInfo[1])) then
                existing_key = data_hash[arrayInfo[1]]
                existing_key.flag = Integer(arrayInfo[2])
                existing_key.time = Time.now + Integer(arrayInfo[3])
                bytes = arrayInfo[4]
                existing_key.bytes = Integer(bytes) + Integer(existing_key.bytes)
                appended_value = (existing_key.value + value)
                existing_key.value = appended_value
                existing_key.cas_value += 1
                return STORED
            else
                return NOT_STORED
            end
        elsif (status.include?(CLIENT_ERROR))
            return status
        else
            return status
        end
    end

    def prepend(arrayInfo, value)
        validator.remove_expired(data_hash)
        status = validator.command_checker_storage(arrayInfo,value)
        if(status.include?(SUCCESS)) then
            if(data_hash.key?(arrayInfo[1])) then
                existing_key = data_hash[arrayInfo[1]]
                existing_key.flag = Integer(arrayInfo[2])
                existing_key.exp_Time = Time.now + Integer(arrayInfo[3])
                bytes = arrayInfo[4]
                existing_key.bytes = Integer(bytes) + Integer(existing_key.bytes)
                appended_value = value + existing_key.value 
                existing_key.value = appended_value
                existing_key.cas_value += 1
                return STORED
            else
                return NOT_STORED
            end
        elsif (status.include?(CLIENT_ERROR))
            return status
        else
            return status
        end
    end

    def cas(arrayInfo, value)
        validator.remove_expired(data_hash)
        status = validator.command_checker_storage(arrayInfo,value)
        if(status.include?(SUCCESS)) then
            if(data_hash.key?(arrayInfo[1])) then
                existing_key = data_hash[arrayInfo[1]]
                if(Integer(existing_key.cas_value) == Integer(arrayInfo[5])) then
                    new_cas = Integer(arrayInfo[5]) + 1
                    array_new_cas = [arrayInfo[0],arrayInfo[1],arrayInfo[2],arrayInfo[3],arrayInfo[4],new_cas]
                    self.set(array_new_cas, value)
                else    
                    EXISTS
                end
            else
                NOT_FOUND
            end
        elsif (status.include?(CLIENT_ERROR))
            return status
        else
            return status
        end
    end

    def get(key_array)
        validator.remove_expired(data_hash)
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
        return output + END_MESSAGE
    end

    def gets(key_array)
        validator.remove_expired(data_hash)
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
        return output + END_MESSAGE
    end

end
    