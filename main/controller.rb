require_relative 'model'

class Controller
  attr_accessor :model

=begin
GENERAL PROTOCOL SPECIFICATION
--------------------------------------------------------------------------------
Storage commands:

set => "store this data".
add => "store this data, but only if the server *doesn't* already hold data for this key".
replace => "store this data, but only if the server *does* already hold data for this key".
append => "add this data to an existing key after existing data".
prepend => "add this data to an existing key before existing data".
cas =>vis a check and set operation which means "store this data but only if no one else has updated since I last fetched it."

<command name> <key> <flags> <exptime> <bytes> [noreply]\r\n

<key> is the key under which the client asks to store the data

<flags> is an arbitrary 16-bit unsigned integer (written out in decimal) that the 
server stores along with the data and sends back when the item is retrieved.

<exptime> is expiration time. If it's 0, the item never expires.
 If it's non-zero, it is guaranteed that clients will not be able to
  retrieve this item after the expiration time arrives.
  Negative = immediately expired.

<bytes> is the number of bytes in the data block to follow, *not*
  including the delimiting \r\n. <bytes> may be zero (in which case
  it's followed by an empty data block).

"noreply" optional parameter instructs the server to not send the reply.

After this line, the client sends the data block:

 - <data block>\r\n

 After sending the command line and the data block the client awaits
the reply, which may be:

- "STORED\r\n"

- "NOT_STORED\r\n" 

- "EXISTS\r\n"

- "NOT_FOUND\r\n" 
--------------------------------------------------------------------------------
Retrieval commands:

get
gets

=end

#--------------------------------------------------------------------------------

=begin
    
Initial command structure:

*User inputs the following:

user> <command name> [arrayInfo]
user> value

arrayInfo = [key, flags, exptime, bytes]
    
=end

  def initialize
    @model = Model.new
  end

  def set(arrayInfo, value)
    key = arrayInfo[0]
    flag = arrayInfo[1]
    expTime = arrayInfo[2]
    bytes = arrayInfo[3]
    return model.set(key, flag, expTime, bytes,value)
  end

end





