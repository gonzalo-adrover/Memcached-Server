require_relative "../main/validator"
require_relative "../main/message"
require_relative "../main/DAO/command_dao"


RSpec.describe Validator do
    let(:validator) { Validator.new }
    let(:command_dao) { CommandDAO.new }
    let(:data) { "Ipsum" }
    let(:data_long) { "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed varius sagittis enim, nec pulvinar justo. Suspendisse non sem nibh. Quisque in quam iaculis, dignissim nunc id, laoreet leo. Phasellus dapibus ipsum vel purus fermentum, vitae tincidunt erat orci." }

    it "Checks that expired keys get removed from the cache" do
        array = ["set", "Lorem", "0", "1", "5"]
        command_dao.set(array,data)
        sleep(1.1)
        expect(command_dao.get("Lorem")).to eq(" \r\n \r\n \r\n \r\nEND\r\n")
    end

    it 'Checks that a standard storage command received is correct' do 
        array = ["set", "Lorem", "0", "600", "5"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(SUCCESS + LINE_BREAK)
    end

    it 'Checks that cas storage command received is correct' do 
        array = ["cas", "Lorem", "0", "600", "5", "1"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(SUCCESS + LINE_BREAK)
    end

    it 'Checks that a standard storage command received is missing an argument' do 
        array = ["set", "Lorem", "0", "600"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + ARGUMENT_ERROR)
    end

    it 'Checks that a standard storage command received is exceeding an argument' do 
        array = ["set", "Lorem", "0", "600", "5", "5"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + ARGUMENT_ERROR)
    end

    it 'Checks that cas storage command received is missing an argument' do 
        array = ["cas", "Lorem", "0", "600"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + ARGUMENT_ERROR)
    end

    it 'Checks that cas storage command received is exceeding an argument' do 
        array = ["cas", "Lorem", "0", "600", "5", "5", "5"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + ARGUMENT_ERROR)
    end

    it 'Checks that the bytes size and length of data block differ' do 
        array = ["set", "Lorem", "0", "600", "4"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + LINE_BREAK)
    end

    it 'Checks that the expiration time set is invalid (negative value)' do 
        array = ["set", "Lorem", "0", "-1", "5"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + TIME_ERROR + LINE_BREAK)
    end

    it 'Checks that the expiration time set is invalid (exceeds limit defined by protocol)' do 
        array = ["set", "Lorem", "0", "2592001", "5"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + TIME_ERROR + LINE_BREAK)
    end

    it 'Checks that bytes size is invalid (exceeds limit defined by protocol)' do 
        array = ["set", "Lorem", "0", "600", "257"]
        result = validator.command_checker_storage(array,data_long)
        expect(result).to eq(CLIENT_ERROR + BYTES_ERROR + LINE_BREAK)
    end

    it 'Checks that flag value entered is invalid (inferior limit)' do 
        array = ["set", "Lorem", "-65537", "600", "5"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + FLAG_ERROR + LINE_BREAK)
    end

    it 'Checks that flag value entered is invalid (superior limit)' do 
        array = ["set", "Lorem", "65537", "600", "5"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + FLAG_ERROR + LINE_BREAK)
    end

    it "Checks that the bytes size and length of data block differ & the expiration time set is invalid" do
        array = ["set", "Lorem", "0", "-1", "4"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + TIME_ERROR + LINE_BREAK)
    end

    it "Checks that the bytes size and length of data block differ & bytes size is invalid" do
        array = ["set", "Lorem", "0", "600", "300"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + BYTES_ERROR + LINE_BREAK)
    end

    it "Checks that the bytes size and length of data block differ & flag value entered is invalid" do
        array = ["set", "Lorem", "65537", "600", "4"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + FLAG_ERROR + LINE_BREAK)
    end

    it "Checks that the expiration time set is invalid & bytes size is invalid" do
        array = ["set", "Lorem", "0", "-1", "257"]
        result = validator.command_checker_storage(array,data_long)
        expect(result).to eq(CLIENT_ERROR + TIME_ERROR + BYTES_ERROR + LINE_BREAK)
    end

    it "Checks that the expiration time set is invalid & flag value entered is invalid" do
        array = ["set", "Lorem", "65537", "-1", "5"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + TIME_ERROR + FLAG_ERROR + LINE_BREAK)
    end

    it "Checks that the bytes size is invalid & flag value entered is invalid" do
        array = ["set", "Lorem", "65537", "600", "257"]
        result = validator.command_checker_storage(array,data_long)
        expect(result).to eq(CLIENT_ERROR + BYTES_ERROR + FLAG_ERROR + LINE_BREAK)
    end

    it "Checks that the bytes size and length of data block differ & the expiration time set is invalid & bytes size is invalid" do
        array = ["set", "Lorem", "0", "-1", "258"]
        result = validator.command_checker_storage(array,data_long)
        expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + TIME_ERROR + BYTES_ERROR + LINE_BREAK)
    end

    it "Checks that the bytes size and length of data block differ & the expiration time set is invalid & flag value entered is invalid" do
        array = ["set", "Lorem", "65537", "-1", "4"]
        result = validator.command_checker_storage(array,data)
        expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + TIME_ERROR + FLAG_ERROR + LINE_BREAK)
    end

    it "Checks that the expiration time set is invalid & bytes size is invalid & flag value entered is invali" do
        array = ["set", "Lorem", "65537", "-1", "257"]
        result = validator.command_checker_storage(array,data_long)
        expect(result).to eq(CLIENT_ERROR + TIME_ERROR + BYTES_ERROR + FLAG_ERROR + LINE_BREAK)
    end

    it "Checks that every possible input error ocurrs" do
        array = ["set", "Lorem", "65537", "-1", "258"]
        result = validator.command_checker_storage(array,data_long)
        expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + TIME_ERROR + BYTES_ERROR + FLAG_ERROR + LINE_BREAK)
    end

end