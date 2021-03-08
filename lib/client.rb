require 'socket'

HOSTNAME = 'localhost'
PORT = 1010

s = TCPSocket.open(HOSTNAME, PORT)
puts 'connected succesfully'

client = s.gets( "\n" ).chomp( "\n" )

puts "message #{client}"

line = s.gets
puts "#{line}"

s.close