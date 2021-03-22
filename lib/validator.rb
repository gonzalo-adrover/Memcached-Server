require_relative 'message'

class Validator

  FLAG_RANGE = (2 ** 16)
  MAX_EXP_TIME = 2592000
  MAX_BYTES = 256

  def command_checker_storage (array, data)
    command = array[0]
    flag = array[2]
    exp_time = array[3]
    bytes = array[4]
    valid_commands = ['set', 'add', 'replace', 'append', 'prepend', 'get', 'gets']
    error = CLIENT_ERROR
    if (command == 'cas' && array.length < 6) || (command == 'cas' && array.length > 7) || (valid_commands.index(command) && array.length < 5) || (valid_commands.index(command) && array.length > 6)
      return error + ARGUMENT_ERROR
    end
    if (valid_commands.index(command) && array.length == 6 && array[5] != 'noreply') || (command == 'cas' && array.length == 7 && array[6] != 'noreply')
      error = error + NOREPLY_ERROR
    end
    if Integer(bytes) != data.length
      error = error + MISMATCH_ERROR
    end
    if Integer(exp_time) < 0 || Integer(exp_time) > MAX_EXP_TIME
      error = error + TIME_ERROR
    end
    if Integer(bytes) > MAX_BYTES
      error = error + BYTES_ERROR
    end
    if Integer(flag) > FLAG_RANGE || Integer(flag) < -FLAG_RANGE
      error = error + FLAG_ERROR
    end
    if Integer(bytes) == data.length && Integer(exp_time) >= 0 && Integer(exp_time) < MAX_EXP_TIME && Integer(bytes) > 0 && Integer(bytes) < MAX_BYTES && Integer(flag) < FLAG_RANGE && Integer(flag) > -FLAG_RANGE && !(valid_commands.index(command) && array.length == 6 && array[5] != 'noreply') && !(command == 'cas' && array.length == 7 && array[6] != 'noreply')
      error = SUCCESS
    end
    error + LINE_BREAK
  end

  def remove_expired(data_hash)
    data_hash.each do |name, key|
      if key.exp_time == 0
        nil
      elsif Time.now > key.exp_time
        data_hash.delete name
      end
    end
  end

  def time_converter(time)
    (Integer(time) > 0) ? Time.now + Integer(time) : 0
  end

  def has_noreply(array)
    (!array.include? 'noreply') ? STORED : LINE_BREAK
  end

  def update_modified_attributes(array_info,data_hash)
    existing_key = data_hash[array_info[1]]
    existing_key.flag = Integer(array_info[2])
    existing_key.exp_time = time_converter(array_info[3])
    bytes = array_info[4]
    existing_key.bytes = Integer(bytes) + Integer(existing_key.bytes)
    existing_key.cas_value += 1
    existing_key
  end

end