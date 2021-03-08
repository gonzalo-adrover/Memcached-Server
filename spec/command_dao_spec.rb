require_relative "../main/message"
require_relative "../main/DAO/command_dao"


RSpec.describe CommandDAO do
    let(:command_dao) { CommandDAO.new }
    let(:array_set) { ["set", "Lorem", "0", "600", "5"] }
    let(:array_add) { ["add", "Lorem", "0", "600", "5"] }
    let(:array_cas) { ["cas", "Lorem", "0", "600", "5", "2"] }    
    let(:array_replace) { ["replace", "Lorem", "10", "600", "4"] }
    let(:array_append) { ["append", "Lorem", "10", "600", "15"] }
    let(:array_prepend) { ["prepend", "Lorem", "10", "600", "6"] }   
    let(:array_cas2) { ["cas", "Lorem", "10", "600", "14", "1"] }
    let(:data) { "Ipsum" }
    let(:data2) { "Sit Amet"}

    it "Sets a key for the first time successfully (without cas value)" do
        result = command_dao.set(array_set,data)
        expect(result).to eq(STORED)
        key = command_dao.data_hash["Lorem"]
        expect(key.key).to eq("Lorem")
        expect(key.flag).to eq(0)
        expect(key.bytes).to eq(5)
        expect(key.value).to eq("Ipsum")  
        expect(key.cas_value).to eq(1)
    end

    it "Sets a key successfully with cas value" do
        result = command_dao.set(array_cas,data)
        expect(result).to eq(STORED)
        key = command_dao.data_hash["Lorem"]
        expect(key.key).to eq("Lorem")
        expect(key.flag).to eq(0)
        expect(key.bytes).to eq(5)
        expect(key.value).to eq("Ipsum")  
        expect(key.cas_value).to eq(2)  
    end

    it "Adds a key successfully" do
        result = command_dao.add(array_add,data)
        expect(result).to eq(STORED)
        key = command_dao.data_hash["Lorem"]
        expect(key.key).to eq("Lorem")
        expect(key.flag).to eq(0)
        expect(key.bytes).to eq(5)
        expect(key.value).to eq("Ipsum")  
        expect(key.cas_value).to eq(1)  
    end

    it "Tries adding an existing key" do
        command_dao.set(array_set,data)
        result = command_dao.add(array_add,data)
        expect(result).to eq(NOT_STORED)
    end

    it "Replaces an existing key successfully" do
        command_dao.set(array_set,data)
        result = command_dao.replace(array_replace,"Amet")
        expect(result).to eq(STORED)
        key = command_dao.data_hash["Lorem"]
        expect(key.key).to eq("Lorem")
        expect(key.flag).to eq(10)
        expect(key.bytes).to eq(4)
        expect(key.value).to eq("Amet")  
        expect(key.cas_value).to eq(2)
    end

    it "Tries replacing an non-existing key" do
        result = command_dao.replace(array_replace,"Amet")
        expect(result).to eq(NOT_STORED)
    end

    it "Appends a value to and existing key" do
        command_dao.set(array_set,data)
        result = command_dao.append(array_append," dolor sit amet")
        expect(result).to eq(STORED)
        key = command_dao.data_hash["Lorem"]
        expect(key.key).to eq("Lorem")
        expect(key.flag).to eq(10)
        expect(key.bytes).to eq(20)
        expect(key.value).to eq("Ipsum dolor sit amet")  
        expect(key.cas_value).to eq(2)
    end

    it "Tries appending a value to an non-existing key" do
        result = command_dao.append(array_append," dolor sit amet")
        expect(result).to eq(NOT_STORED)
    end

    it "Prepends a value to and existing key" do
        command_dao.set(array_set,data)
        result = command_dao.prepend(array_prepend,"Lorem ")
        expect(result).to eq(STORED)
        key = command_dao.data_hash["Lorem"]
        expect(key.key).to eq("Lorem")
        expect(key.flag).to eq(10)
        expect(key.bytes).to eq(11)
        expect(key.value).to eq("Lorem Ipsum")  
        expect(key.cas_value).to eq(2)
    end

    it "Tries prepending a value to an non-existing key" do
        result = command_dao.prepend(array_prepend,"Lorem ")
        expect(result).to eq(NOT_STORED)
    end

    it "Cas sets the data if not updated since last fetch (cas - STORED)" do
        command_dao.set(array_set,data)
        result = command_dao.cas(array_cas2,"Dolor sit amet")
        expect(result).to eq(STORED)
        key = command_dao.data_hash["Lorem"]
        expect(key.key).to eq("Lorem")
        expect(key.flag).to eq(10)
        expect(key.bytes).to eq(14)
        expect(key.value).to eq("Dolor sit amet")  
        expect(key.cas_value).to eq(2)
    end

    it "Tries setting cas data but it was updated since last fetch (cas - EXISTS)" do
        command_dao.set(array_set,data)
        result = command_dao.prepend(array_prepend,"Lorem ")
        result = command_dao.cas(array_cas2,"Dolor sit amet")
        expect(result).to eq(EXISTS)
    end

    it "Tries setting cas data to a non-existing key" do
        result = command_dao.cas(array_cas2,"Dolor sit amet")
        expect(result).to eq(NOT_FOUND)
    end

    it "Retrieves one key with get command" do
        command_dao.set(array_set,data)
        result = command_dao.get(["get","Lorem"])
        expect(result).to eq("VALUE Lorem 0 5\r\nIpsum\r\nEND\r\n")
    end

    it "Retrieves two keys with get command" do
        command_dao.set(array_set,data)
        command_dao.set(["set", "Dolor", "10", "600", "8"], data2)
        result = command_dao.get(["get", "Lorem", "Dolor"])
        expect(result).to eq("VALUE Lorem 0 5\r\nIpsum\r\nVALUE Dolor 10 8\r\nSit Amet\r\nEND\r\n")
    end

    it "Retrieves an existing key and a non-existing key get command" do
        command_dao.set(array_set,data)
        result = command_dao.get(["get", "Lorem", "Dolor"])
        expect(result).to eq("VALUE Lorem 0 5\r\nIpsum\r\n \r\nEND\r\n")
    end

    it "Tries retrieving a non-existing key with get command" do
        result = command_dao.get(["get", "Lorem"])
        expect(result).to eq(" \r\nEND\r\n")
    end

    it "Retrieves one key with gets command" do
        command_dao.set(array_cas,data)
        result = command_dao.gets(["get","Lorem"])
        expect(result).to eq("VALUE Lorem 0 5 2\r\nIpsum\r\nEND\r\n")
    end
    
    it "Retrieves two keys with gets command" do
        command_dao.set(array_cas,data)
        command_dao.set(["set", "Dolor", "10", "600", "8"], data2)
        result = command_dao.gets(["gets", "Lorem", "Dolor"])
        expect(result).to eq("VALUE Lorem 0 5 2\r\nIpsum\r\nVALUE Dolor 10 8 1\r\nSit Amet\r\nEND\r\n")
    end

    it "Retrieves a non-existing key and an existing key gets command" do
        command_dao.set(array_set,data)
        result = command_dao.gets(["gets", "Dolor", "Lorem"])
        expect(result).to eq(" \r\nVALUE Lorem 0 5 1\r\nIpsum\r\nEND\r\n")
    end

    it "Tries retrieving a non-existing key with gets command" do
        result = command_dao.gets(["gets", "Lorem"])
        expect(result).to eq(" \r\nEND\r\n")
    end

end