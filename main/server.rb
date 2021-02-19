require 'socket'
require_relative 'controller'

class Server
  controller = Controller.new

  PORT   = 1010
  server = TCPServer.open(PORT)

  puts "Listening on #{PORT}."

    # Socket to listen on port 2000
  loop {                           # Servers run forever
    Thread.start(server.accept) do |client|
      puts "New client: #{client}"
      client.puts("Hello world from server")
      client.puts "1"

      while line = client.gets
        puts "2"

        request = line.split
        command = request[0]

        case command
        when "set"
          
          puts "3"
          value = client.gets( "\r\n" ).chomp( "\r\n" )
          response = controller.set(request,value)
        end
      end
    end
  }
end