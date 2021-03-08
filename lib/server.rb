require 'socket'
require_relative 'DAO/dao'
require_relative 'message'
require_relative 'validator'


class Server
      dao = DAO.new
      validator = Validator.new

      PORT   = 1010
      server = TCPServer.open(PORT)

      puts "Listening on Port: #{PORT}."

      loop {                           
            Thread.start(server.accept) do |client|
                  puts "New client: #{client}"
                  client.puts("Welcome to the Memcached Server!\r\nYou can start using the server now, or type 'help' for command instructions.\r\n")

                  while line = client.gets

                        array_info = line.split
                        command = array_info[0]

                        case command
                        when "set"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              status = validator.command_checker_storage(array_info,data_block)
                              result = (status.include?(SUCCESS)) ? dao.set(array_info,data_block) : status
                              client.puts(result)
                        when "add"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              status = validator.command_checker_storage(array_info,data_block)
                              result = (status.include?(SUCCESS)) ? dao.add(array_info,data_block) : status
                              client.puts(result)
                        when "replace"   
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              status = validator.command_checker_storage(array_info,data_block)
                              result = (status.include?(SUCCESS)) ? dao.replace(array_info,data_block) : status
                              client.puts(result)
                        when "append"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              status = validator.command_checker_storage(array_info,data_block)
                              result = (status.include?(SUCCESS)) ? dao.append(array_info,data_block) : status
                              client.puts(result)
                        when "prepend"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              status = validator.command_checker_storage(array_info,data_block)
                              result = (status.include?(SUCCESS)) ? dao.prepend(array_info,data_block) : status
                              client.puts(result)
                        when "cas"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              status = validator.command_checker_storage(array_info,data_block)
                              result = (status.include?(SUCCESS)) ? dao.cas(array_info,data_block) : status
                              client.puts(result)
                        when "get"
                              result = dao.get(array_info)
                              client.puts(result)
                        when "gets"
                              result = dao.gets(array_info)
                              client.puts(result)
                        when "help"
                              client.puts(INSTRUCTIONS)
                        else
                              client.puts(ERROR)
                        end
                  end
            end
      }
end