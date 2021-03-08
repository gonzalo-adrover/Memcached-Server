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

In order to setup and run the server open the Terminal inside the */main* directory. Once inside, execute the following command:

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

### Running the server

Only after the server is already set, open another Terminal window and type:

```
telnet localhost 1010
```

If the server is listening for connections and the client connects successfully, you will see this message pop up in the window:

![alt text](https://imgur.com/a/Sp82mpW)

Now everything is ready for its proper usage. If it is your first time interacting with a Memcached server, you may use the 'info' command for instructions on how to get started.

## List of available commands

There are two kind of commands a client may utilize to work with the Memcached server, **storage** and **retrieval** commands.

### Storage Commands

Every storage command except for 'cas' has the following structure: 

```
<command name> <key> <flags> <exptime> <bytes> *Press the enter key*
<data block>
```

For 'cas' it is the same as before but a 'cas value' needs to be added:

```
cas <key> <flags> <exptime> <bytes> <cas value> *Press the enter key*
<data block>
```

***Examples:***

* set

```
set Marco 10 600 4
Polo
```

* add

```
add Marco 10 600 4
Polo
```

* replace

```
replace Marco 10 600 4
Polo
```

* append

```
append Marco 10 600 13
 was a Sailor
```

* prepend

```
prepend Marco 10 600 4
Sir. 
```

* cas

```
cas Marco 10 600 4
John
```

### Storage Commands

* get

* gets

## Running the tests

Explain existing tests

### Command DAO tests

Explain what these tests test and why

```
Give an example
```

### Validator tests

Explain what these tests test and why

```
Give an example
```

## Built With

* [Memcached](link) - T
* [Ruby](link) - T
* [RSpec](link) - T

## Structure?

X

## Versioning

Version 1.1.0 

## Authors

* **Gonzalo Adrover** - [Github](https://github.com/gonzalo-adrover)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Algo

