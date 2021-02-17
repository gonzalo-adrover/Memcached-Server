require 'socket'

PORT   = 1010
server = TCPServer.open(PORT)

puts "Listening on #{PORT}."

  # Socket to listen on port 2000
loop {                           # Servers run forever
   Thread.start(server.accept) do |client|
    puts "New client: #{client}"
    client.puts("Hello world from server")
    client.puts("Current time is: " + Time.now.ctime)   # Send the time to the client
    client.puts "Closing the connection. Bye!"
    client.close                  # Disconnect from the client
   end
}