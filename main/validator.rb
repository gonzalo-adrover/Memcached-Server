require_relative 'message'

class Validator

    FLAG_RANGE = (2**16)
    MAX_EXP_TIME = 2592000
    MAX_BYTES= 256

    def remove_expired(data_hash)
        data_hash.each do |name,key|
            if (Time.now > key.exp_Time) then 
                data_hash.delete name
            end
        end
    end

    def command_checker_retrieval (array)
        command = array[0]
        valid_commands = ["get","gets"]
        if(!valid_commands.index(command)) then
            return ERROR
        end
    end

    def command_checker_storage (array,data)
        command = array[0]
        flag = array[2]
        exp_Time = array[3]
        bytes = array[4]
        valid_commands = ["set","add","replace","append","prepend","cas","get","gets"]
        error = ""
        if(valid_commands.index(command)) then
            error = CLIENT_ERROR
            valid_commands.delete("cas")
            if ((command == 'cas' && array.length != 6) || (valid_commands.index(command) && array.length != 5)) then 
                return error + ARGUMENT_ERROR
            end
            if (Integer(bytes) != data.length) then
                error = error + MISMATCH_ERROR
            end 
            if (Integer(exp_Time) < 0 || Integer(exp_Time) > MAX_EXP_TIME) then
                error = error + TIME_ERROR
            end
            if (Integer(bytes) < 0 || Integer(bytes) > MAX_BYTES) then
                error = error + BYTES_ERROR
            end
            if (Integer(flag) > FLAG_RANGE || Integer(flag) < -FLAG_RANGE) then
                error = error + FLAG_ERROR
            end
            if (Integer(bytes) == data.length && Integer(exp_Time) > 0 && Integer(exp_Time) < MAX_EXP_TIME && Integer(bytes) > 0 && Integer(bytes) < MAX_BYTES && Integer(flag) < FLAG_RANGE && Integer(flag) > -FLAG_RANGE ) then
                error = SUCCESS
            end
            return error + LINE_BREAK
        else 
            return error = ERROR
        end
    end


end