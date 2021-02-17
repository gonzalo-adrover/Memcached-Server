require 'socket'

HOSTNAME = 'localhost'
PORT = 1010

s = TCPSocket.open(HOSTNAME, PORT)

while line = s.gets     
    puts line.chomp  
end
s.close                 