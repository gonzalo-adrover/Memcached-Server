require 'socket'

PORT   = 1010
socket = TCPServer.open(PORT)

puts "Listening on #{PORT}."

def handle_connection(client)
    puts "New client: #{client}"
    client.write("Hello world from server")
    client.close
end

loop do
    client = socket.accept
    Thread.new { handle_connection(client) }
end
  