# frozen_string_literal: true

require_relative 'command'
require_relative '../message'
require_relative '../validator'
require 'date'

class CommandDAO
  attr_accessor :data_hash, :cas_value, :validator

  def initialize
    @data_hash = {}
    @validator = Validator.new
    @cas_value = 1
  end

  def set(array_info, value)
    exp_time = validator.time_converter(array_info[3])
    case array_info.length
    when 5
      full_key = Command.new(array_info[1], Integer(array_info[2]), exp_time, Integer(array_info[4]), value, cas_value)
      data_hash.store(array_info[1], full_key)
      STORED
    when 6
      full_key = Command.new(array_info[1], Integer(array_info[2]), exp_time, Integer(array_info[4]), value, cas_value)
      data_hash.store(array_info[1], full_key)
      LINE_BREAK
    when 7
      if !array_info.include? 'noreply'
        full_key = Command.new(array_info[1], Integer(array_info[2]), exp_time, Integer(array_info[4]), value,
                               Integer(array_info[5]))
        data_hash.store(array_info[1], full_key)
        STORED
      else
        full_key = Command.new(array_info[1], Integer(array_info[2]), exp_time, Integer(array_info[4]), value,
                               Integer(array_info[5]))
        data_hash.store(array_info[1], full_key)
        LINE_BREAK
      end
    else
      ERROR
    end
  end

  def add(array_info, value)
    if !data_hash.key?(array_info[1])
      exp_time = validator.time_converter(array_info[3])
      full_key = Command.new(array_info[1], Integer(array_info[2]), exp_time, Integer(array_info[4]), value, cas_value)
      data_hash.store(array_info[1], full_key)
      validator.has_noreply(array_info)
    else
      NOT_STORED
    end
  end

  def replace(array_info, value)
    if data_hash.key?(array_info[1])
      existing_key = data_hash[array_info[1]]
      existing_key.cas_value += 1
      exp_time = validator.time_converter(array_info[3])
      data_hash.delete array_info[1]
      full_key = Command.new(array_info[1], Integer(array_info[2]), exp_time, Integer(array_info[4]), value,
                             existing_key.cas_value)
      data_hash.store(array_info[1], full_key)
      validator.has_noreply(array_info)
    else
      NOT_STORED
    end
  end

  def append(array_info, value)
    if data_hash.key?(array_info[1])
      validator.update_modified_attributes(array_info,data_hash)
      existing_key = data_hash[array_info[1]]
      existing_key.value = (existing_key.value + value)
      validator.has_noreply(array_info)
    else
      NOT_STORED
    end
  end

  def prepend(array_info, value)
    if data_hash.key?(array_info[1])
      validator.update_modified_attributes(array_info,data_hash)
      existing_key = data_hash[array_info[1]]
      existing_key.value = value + existing_key.value
      validator.has_noreply(array_info)
    else
      NOT_STORED
    end
  end

  def cas(array_info, value)
    if data_hash.key?(array_info[1])
      existing_key = data_hash[array_info[1]]
      if Integer(existing_key.cas_value) == Integer(array_info[5])
        new_cas = Integer(array_info[5]) + 1
        array_new_cas = [array_info[0], array_info[1], array_info[2], array_info[3], array_info[4], new_cas, array_info[6]]
        set(array_new_cas, value)
      else
        EXISTS
      end
    else
      NOT_FOUND
    end
  end

  def getter(key_array, type)
    i = 1
    n = key_array.length
    output = ''
    until i == n
      key = key_array[i]
      command = data_hash[key]
      i += 1
      output = if data_hash.key?(key)
                 if type == 'gets'
                   output + "VALUE #{command.key} #{command.flag} #{command.bytes} #{command.cas_value}\r\n#{command.value}\r\n"
                 elsif type == 'get'
                   output + "VALUE #{command.key} #{command.flag} #{command.bytes}\r\n#{command.value}\r\n"
                 end
               else
                 "#{output} \r\n"
               end
    end
    output + END_MESSAGE
  end

  def remove_expired()
    data_hash.each do |name, key|
      if key.exp_time == 0
        nil
      elsif Time.now > key.exp_time
        data_hash.delete name
      end
    end
  end

end
