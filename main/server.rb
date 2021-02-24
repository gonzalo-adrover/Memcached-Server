require 'socket'
require_relative 'controller/controller'
require 'pp'

class Server
      controller = Controller.new

      PORT   = 1010
      server = TCPServer.open(PORT)

      puts "Listening on #{PORT}."

      loop {                           
            Thread.start(server.accept) do |client|
            puts "New client: #{client}"
            client.puts("Hello world from server")

            while line = client.gets

                  array_info = line.split
                  command = array_info[0]

                  case command
                        when "set"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = controller.set(array_info,data_block)
                              client.puts(result)
                        when "add"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = controller.add(array_info,data_block)
                              client.puts(result)
                        when "replace"   
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = controller.replace(array_info,data_block)
                              client.puts(result)
                        when "append"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = controller.append(array_info,data_block)
                              client.puts(result)
                        when "prepend"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = controller.prepend(array_info,data_block)
                              client.puts(result)
                        when "cas"
                              data_block = client.gets( "\r\n" ).chomp( "\r\n" )
                              result = controller.cas(array_info,data_block)
                              client.puts(result)
                        when "get"
                              result = controller.get(array_info)
                              client.puts(result)
                        when "gets"
                              result = controller.gets(array_info)
                              client.puts(result)
                        end
                  end
            end
      }
end