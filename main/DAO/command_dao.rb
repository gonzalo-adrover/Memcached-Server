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
        self.remove_expired
        status = self.command_checker_storage(arrayInfo,value)
        if(status.include?("success")) then
                self.cas_value += 1
                exp_time = Time.now + Integer(arrayInfo[3])
                full_key = Command.new(arrayInfo[1],arrayInfo[2],exp_time,arrayInfo[4],value,cas_value)
                data_hash.store(arrayInfo[1],full_key)
                return "STORED\r\n"
        elsif (status.include?("CLIENT_ERROR"))
            return status
        else
            return status
        end
    end

    def add(arrayInfo, value)
        self.remove_expired
        status = self.command_checker_storage(arrayInfo,value)
        if(status.include?("success")) then
           if(!data_hash.key?(arrayInfo[1])) then
                self.cas_value += 1
                exp_time = Time.now + Integer(arrayInfo[3])
                full_key = Command.new(arrayInfo[1],arrayInfo[2],exp_time,arrayInfo[4],value,cas_value)
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

    def replace(arrayInfo, value)
        self.remove_expired
        status = self.command_checker_storage(arrayInfo,value)
        if(status.include?("success")) then
            if(data_hash.key?(arrayInfo[1])) then
                self.cas_value += 1
                exp_time = Time.now + Integer(arrayInfo[3])
                data_hash.delete arrayInfo[1]
                full_key = Command.new(arrayInfo[1],arrayInfo[2],exp_time,arrayInfo[4],value,cas_value)
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

    def append(arrayInfo, value)
        self.remove_expired
        status = self.command_checker_storage(arrayInfo,value)
        if(status.include?("success")) then
            if(data_hash.key?(arrayInfo[1])) then
                self.cas_value += 1
                existing_key = data_hash[arrayInfo[1]]
                existing_key.flag = arrayInfo[2]
                existing_key.time = Time.now + Integer(arrayInfo[3])
                bytes = arrayInfo[3]
                existing_key.bytes = Integer(bytes) + Integer(existing_key.bytes)
                appended_value = existing_key.value + value
                existing_key.value = appended_value
                existing_key.cas_value = cas_value
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

    def prepend(arrayInfo, value)
        self.remove_expired
        status = self.command_checker_storage(arrayInfo,value)
        if(status.include?("success")) then
            if(data_hash.key?(arrayInfo[1])) then
                self.cas_value += 1
                existing_key = data_hash[arrayInfo[1]]
                existing_key.flag = arrayInfo[2]
                existing_key.time = Time.now + Integer(arrayInfo[3])
                bytes = arrayInfo[3]
                existing_key.bytes = Integer(bytes) + Integer(existing_key.bytes)
                appended_value = value + existing_key.value 
                existing_key.value = appended_value
                existing_key.cas_value = cas_value
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

    def cas(arrayInfo, value)
        self.remove_expired
        status = self.command_checker_storage(arrayInfo,value)
        if(status.include?("success")) then
            if(data_hash.key?(arrayInfo[1])) then
                existing_key = data_hash[arrayInfo[1]]
                if(Integer(existing_key.cas_value) == Integer(arrayInfo[5])) then
                    new_cas = Integer(arrayInfo[5]) + 1
                    array_new_cas = [arrayInfo[0],arrayInfo[1],arrayInfo[2],arrayInfo[3],arrayInfo[4],new_cas]
                    self.set(arrayInfo, value) #partir el array y subirle en uno el cas value
                else    
                    "EXISTS\r\n"
                end
            else
                "NOT_FOUND\r\n"
            end
        elsif (status.include?("CLIENT_ERROR"))
            return status
        else
            return status
        end
    end

    def get(key_array)
        self.remove_expired
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
        self.remove_expired
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

    def remove_expired()
        data_hash.each do |name,key|
            if (Time.now > key.expTime) then 
                data_hash.delete name
            end
        end
    end

    def command_checker_retrieval (array)
        command = array[0]
        valid_commands = ["get","gets"]
        error = ""
        if(!valid_commands.index(command)) then
            return "ERROR"
        end
    end

    def command_checker_storage (array,data)
        command = array[0]
        flag = array[2]
        expTime = array[3]
        bytes = array[4]
        valid_commands = ["set","add","replace","append","prepend","cas","get","gets"]
        error = ""
        if(valid_commands.index(command)) then
            error = "CLIENT_ERROR"
            if ((command == 'cas' && array.length != 6) || (valid_commands.index(command) && array.length != 5)) then 
                return error + " - Invalid command, check for missing/exceding arguments\r\n"
            end
            if (Integer(bytes) != data.length) then
                error = error + " - Bytes and length of data block do not match"
            end 
            if (Integer(expTime) < 0 || Integer(expTime) > MAX_EXP_TIME) then
                error = error + " - Invalid expiration time"
            end
            if (Integer(bytes) < 0 || Integer(bytes) > MAX_BYTES) then
                error = error + " - Invalid bytes size"
            end
            if (Integer(flag) > FLAG_RANGE || Integer(flag) < -FLAG_RANGE) then
                error = error + " - Inavlid flag"
            end
            if (Integer(bytes) == data.length && Integer(expTime) > 0 && Integer(expTime) < MAX_EXP_TIME && Integer(bytes) > 0 && Integer(bytes) < MAX_BYTES && Integer(flag) < FLAG_RANGE && Integer(flag) > -FLAG_RANGE ) then
                error = "success"
            end
            return error + "\r\n"
        else 
            return error = "ERROR\r\n"
        end
    end

end
    