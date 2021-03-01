require 'socket'
require_relative 'DAO/dao'
require 'pp'

class Server
      dao = DAO.new

      PORT   = 1010
      server = TCPServer.open(PORT)

      puts "Listening on #{PORT}."

      loop {                           
            Thread.start(server.accept) do |client|
                  puts "New client: #{client}"
                  client.puts("Hello world from server\r\n")

                  while line = client.gets

                        array_info = line.split
                        command = array_info[0]

                        case command
                        when "set"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = dao.set(array_info,data_block)
                              client.puts(result)
                        when "add"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = dao.add(array_info,data_block)
                              client.puts(result)
                        when "replace"   
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = dao.replace(array_info,data_block)
                              client.puts(result)
                        when "append"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = dao.append(array_info,data_block)
                              client.puts(result)
                        when "prepend"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = dao.prepend(array_info,data_block)
                              client.puts(result)
                        when "cas"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = dao.cas(array_info,data_block)
                              client.puts(result)
                        when "get"
                              result = dao.get(array_info)
                              client.puts(result)
                        when "gets"
                              result = dao.gets(array_info)
                              client.puts(result)
                        end
                  end
            end
      }
end