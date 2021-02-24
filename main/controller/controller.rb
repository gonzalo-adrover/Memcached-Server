require_relative '../model/command_dao'

class Controller
    attr_accessor :command_dao

    def initialize
        @command_dao = CommandDAO.new
    end
  
    def set(array_info, data_block)
        return command_dao.set(array_info,data_block)
    end

    def add(array_info, data_block)
        return command_dao.add(array_info, data_block)
    end

    def replace(array_info, data_block)
        return command_dao.replace(array_info, data_block)
    end

    def append(array_info, data_block)
        return command_dao.append(array_info, data_block)
    end

    def prepend(array_info, data_block)
        return command_dao.prepend(array_info, data_block)
    end

    def cas(array_info, data_block)
        return command_dao.cas(array_info, data_block)
    end

    def get(key)
        return command_dao.get(key)
    end
        
    def gets(key)
        return command_dao.gets(key)
    end
  
end