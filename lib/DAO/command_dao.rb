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
    validator.remove_expired(data_hash)
    exp_time = validator.time_converter(array_info[3])
    case array_info.length
    when 5
      full_key = Command.new(array_info[1], Integer(array_info[2]), exp_time, Integer(array_info[4]), value, cas_value)
      data_hash.store(array_info[1], full_key)
      STORED
    when 6
      full_key = Command.new(array_info[1], Integer(array_info[2]), exp_time, Integer(array_info[4]), value,
                             cas_value)
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
    end
  end

  def add(array_info, value)
    validator.remove_expired(data_hash)
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
    validator.remove_expired(data_hash)
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

  def update_modified_attributes(array_info)
    existing_key = data_hash[array_info[1]]
    existing_key.flag = Integer(array_info[2])
    existing_key.exp_time = validator.time_converter(array_info[3])
    bytes = array_info[4]
    existing_key.bytes = Integer(bytes) + Integer(existing_key.bytes)
    existing_key.cas_value += 1
    return existing_key
  end

  def append(array_info, value)
    validator.remove_expired(data_hash)
    if data_hash.key?(array_info[1])
      update_modified_attributes(array_info)
      existing_key = data_hash[array_info[1]]
      existing_key.value = (existing_key.value + value)
      validator.has_noreply(array_info)
    else
      NOT_STORED
    end
  end

  def prepend(array_info, value)
    validator.remove_expired(data_hash)
    if data_hash.key?(array_info[1])
      update_modified_attributes(array_info)
      existing_key = data_hash[array_info[1]]
      existing_key.value = value + existing_key.value
      validator.has_noreply(array_info)
    else
      NOT_STORED
    end
  end

  def cas(array_info, value)
    validator.remove_expired(data_hash)
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

  def get(key_array)
    validator.remove_expired(data_hash)
    i = 1
    n = key_array.length
    output = ''
    until i == n
      key = key_array[i]
      command = data_hash[key]
      i += 1
      output = if data_hash.key?(key)
                 output + "VALUE #{command.key} #{command.flag} #{command.bytes}\r\n#{command.value}\r\n"
               else
                 "#{output} \r\n"
               end
    end
    output + END_MESSAGE
  end

  def gets(key_array)
    validator.remove_expired(data_hash)
    i = 1
    n = key_array.length
    output = ''
    until i == n
      key = key_array[i]
      command = data_hash[key]
      i += 1
      output = if data_hash.key?(key)
                 output + "VALUE #{command.key} #{command.flag} #{command.bytes} #{command.cas_value}\r\n#{command.value}\r\n"
               else
                 "#{output} \r\n"
               end
    end
    output + END_MESSAGE
  end
end
