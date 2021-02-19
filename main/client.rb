require 'socket'

HOSTNAME = 'localhost'
PORT = 1010

s = TCPSocket.open(HOSTNAME, PORT)
puts 'connected succesfully'

#command = gets
#s.puts command

while line = s.gets
  puts line
end

s.close