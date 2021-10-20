# Memcached Server Challenge

Implementation of a Memcached Server (TCP/IP socket) using the Ruby programming language. This server allows the connection of multiple clients to an established server in port 1010 and incorporates the fundamental commands for its use.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

In order to run and test the server, first you will need to clone this repository. 

The easiest way is through the Git Bash console. For doing this open the Git Bash console from the directory where you want the project to be located and type: 

```
$ git clone https://github.com/gonzalo-adrover/MemcachedChallenge.git
```

You will also need to to have installed the **Ruby programming language** and the **RSpec Gem**.

First install **Ruby** by following the instructions in the following link: [RubyInstaller](https://rubyinstaller.org/)

And then proceed to install **RSpec** by typing this command from anywhere in the Terminal:

```
gem install rspec
```

### Running the server

In order to setup and run the server open the Terminal inside the ***/lib*** directory. Once inside, execute the following command:

```
ruby server.rb
```

Once the server starts it will display this message:

```
Listening on 1010.
```

Each time a client connects successfully to the server, their id will be logged like such:

```
New client: #<TCPSocket:0x000000000XXXXXXX>
```

### Running the client

Only after the server is already set, open another Terminal window and type:

```
telnet localhost 1010
```

If the server is listening for connections and the client connects successfully, you will see this message pop up in the window:

![](/Welcome-client.png)

Now everything is ready for its proper usage. If it is your first time interacting with a Memcached server, you may use the 'info' command for instructions on how to get started.

## List of available commands

There are two kind of commands a client may utilize to work with the Memcached server, **storage** and **retrieval** commands.

### Storage Commands

Every storage command except for 'cas' has the following structure: 

```
<command name> <key> <flags> <exptime> <bytes> [noreply] *Press the enter key*
<data block>
```

For 'cas' it is the same as before but a 'cas value' needs to be added at the end of the statement:

```
cas <key> <flags> <exptime> <bytes> <cas value> [noreply] *Press the enter key*
<data block>
```

Where:

**key** - is the reference name for how the server stores the data.

**flags** - is an arbitrary 16-bit unsigned integer that is stored with the key that aids as a field to store data-specific information.

**exptime** - is for how long in seconds will the item be stored. If it is 0, the item will never expire, if it is a negative value it will not be stored.

**bytes** - lenght in bytes of the data block to follow.

**cas unique** - is a unique 64-bit value of an existing entry. Clients should use the value returned from the "gets" command when issuing "cas" updates.

**noreply** -  optional parameter that instructs the server to not send the reply message, it just responds a line break to show the command went through successfully.

***Commands:***

---
**set** - The set command tells the server to directly store the information contained in the command. 
A neutral set command looks like this:
```
set <key> <flags> <exptime> <bytes> [noreply]
<data block>
```
'**set**' command example:
```
set Marco 10 600 4
Polo
```
The possible responses from the server are: **STORED** and **ERROR**

---
**add** - The add command stores the data **only** if the server ***does not*** hold any data for that key, meaning that it will never overwrite an existing key.
A neutral add command looks like this:
```
add <key> <flags> <exptime> <bytes> [noreply]
<data block>
```
'**add**' command example:

```
add Marco 10 600 4
Polo
```
The possible responses from the server are: **STORED**, **NOT STORED** and **ERROR**

---
**replace** - The replace command stores the data **only** if the server ***does*** hold any data for that key, meaning that it will only overwrite existing keys.
A neutral replace command looks like this:
```
replace <key> <flags> <exptime> <bytes> [noreply]
<data block>
```
'**replace**' command example:

```
replace Marco 10 600 4 [noreply]
Polo
```
The possible responses from the server are: **STORED**, **NOT STORED** and **ERROR**

---
**append** - The append command adds data to an existing key after its existing data.
A neutral set command looks like this:
```
append <key> <flags> <exptime> <bytes> [noreply]
<data block>
```
'**append**' command example:
```
append Marco 10 600 13
 was a Sailor
```
The possible responses from the server are: **STORED**, **NOT STORED** and **ERROR**

---
**prepend** - The prepend command adds data to an existing key before its existing data.
A neutral prepend command looks like this:
```
prepend <key> <flags> <exptime> <bytes> [noreply]
<data block>
```
'**prepend**' command example:
```
prepend Marco 10 600 4
Sir.
```
The possible responses from the server are: **STORED**, **NOT STORED** and **ERROR** 

---
**cas** - The cas command a check and set operation which means "store this data but only if no one else has updated since I last fetched it."
A neutral cas command looks like this:
```
cas <key> <flags> <exptime> <bytes> <cas value> [noreply]
<data block>
```
'**cas**' command example:
```
cas Marco 10 600 4 1
John
```
The possible responses from the server are: **STORED**, **EXISTS**, **NOT FOUND** and **ERROR**

---
### Retrieval Commands
Every retrieval command has the following structure: 

```
<command name> <key1> <key2> ... <keyN>
```
Where:

**key** - is a key under which the client stores the data.

***Commands:***

---
**get** - The get command retrieves the key, flag, bytes and value information stored for the solicited key(s).
A neutral get command output looks like this: 
```
VALUE <key> <flags> <bytes>
<data block>
```
'**get**' command output example:
```
VALUE Marco 10 4
John
```
For keys that are not stored in memory it outputs a blank line break.

---
**gets** - The get command retrieves the key, flag, bytes, cas value and value information stored for the solicited key(s).
A neutral gets command output looks like this: 
```
VALUE <key> <flags> <bytes> <cas value>
<data block>
```
'**gets**' command output example:
```
VALUE Marco 10 4 1
John
```
For keys that are not stored in memory it outputs a blank line break.
 
---
## Tests

For testing this project the aforementioned RSpec Gem is used. With the help of this Gem, all the methods for the two main logical classes are tested. Said classes are: **CommandDAO** and **Validator**. 
In order to run the tests, open the Terminal in the ***/MemcachedChallenge*** and run the following command:

```
rspec
```
After all tests are finished, an 'examples.txt' file is generated inside the ***/spec*** folder. This file contains the example_id, status and run_time for each individual test.  

### Command DAO tests

The CommandDAO tests are located in the ***/spec*** folder in the **command_dao_spec.rb**. 

The methods tested are:
* set
* add
* replace
* append
* prepend
* cas
* getter
* remove_expired

The main objective of this tests consists in forcefully manipulating items inside the Hash, and then comparing its expected value with the one returned by the CommandDAO methods.

### Validator tests

The Validator tests are located in the ***/spec*** folder in the **validator_spec.rb**.

The methods tested are:
* command_checker_storage
* time_converter
* has_noreply
* update_modified_attributes

Most of the tests here focus on getting all the possible CLIENT_ERROR messages by purposefully sending commands that do not comply with the protocol. This is done to verify that the client will always receive an expected response depending on the scenario.

## Structure

This project utilizes the Data Access Object Pattern to separate low level data accessing operations from high level services. This is done so all the commands issued by the client go through a lower layer of before accessing the backend model and therefore separating the bussiness logic from the access information logic.

For the prevention of possible race conditions, a Mutex is utilized from the server side. This Semaphore allows only one client connection when interacting with the server in its critical section thus controlling the mutual exclusion problem. This semaphore is being constantly locked and unlocked upon every request. If a client sends a request and another client has the Semaphore's permit, its command gets queued unitil the Mutex is free.

## Built With

* [Memcached protocol](https://github.com/memcached/memcached/blob/master/doc/protocol.txt) - This is the Memcached protocol from where all the behaviour is based.
* [Ruby](https://www.ruby-lang.org/es/) - Language used to program the project.
* [RSpec](https://rspec.info/) - Gem used for testing.

## Versioning

Version 1.0.1

## Author

* **Gonzalo Adrover** - [Github](https://github.com/gonzalo-adrover)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Future improvements

Incorporate a timeout functionality for client's second command (only storage), in order to allow only a max time to set the value and not consume the Semaphore indefinitely, not allowing other clients to interact.
