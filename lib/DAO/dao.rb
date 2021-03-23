# frozen_string_literal: true

require_relative 'command_dao'

class DAO
  attr_accessor :command_dao

  def initialize
    @command_dao = CommandDAO.new
  end

  def set(array_info, data_block)
    command_dao.set(array_info, data_block)
  end

  def add(array_info, data_block)
    command_dao.add(array_info, data_block)
  end

  def replace(array_info, data_block)
    command_dao.replace(array_info, data_block)
  end

  def append(array_info, data_block)
    command_dao.append(array_info, data_block)
  end

  def prepend(array_info, data_block)
    command_dao.prepend(array_info, data_block)
  end

  def cas(array_info, data_block)
    command_dao.cas(array_info, data_block)
  end

  def get(key)
    command_dao.getter(key,'get')
  end

  def gets(key)
    command_dao.getter(key,'gets')
  end

  def remove_expired()
    command_dao.remove_expired
  end
end
