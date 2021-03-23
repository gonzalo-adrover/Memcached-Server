require_relative '../lib/validator'
require_relative '../lib/message'
require_relative '../lib/DAO/command_dao'

RSpec.describe Validator do
  let(:validator) { Validator.new }
  let(:command_dao) { CommandDAO.new }
  let(:data) { 'Ipsum' }
  let(:data_long) { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed varius sagittis enim, nec pulvinar justo. Suspendisse non sem nibh. Quisque in quam iaculis, dignissim nunc id, laoreet leo. Phasellus dapibus ipsum vel purus fermentum, vitae tincidunt erat orci.' }

  it 'Checks that a set command (len = 5) is correct' do
    array = ['set', 'Lorem', '0', '600', '5']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(SUCCESS + LINE_BREAK)
  end

  it 'Checks that set command (len = 6) is correct' do
    array = ['cas', 'Lorem', '0', '600', '5', '1']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(SUCCESS + LINE_BREAK)
  end

  it 'Checks that set command is missing an argument' do
    array = ['set', 'Lorem', '0', '600']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + ARGUMENT_ERROR)
  end

  it 'Checks that set command is exceeding an argument' do
    array = ['set', 'Lorem', '0', '600', '5', 'noreply','0']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + ARGUMENT_ERROR)
  end

  it 'Checks that cas command received is missing an argument' do
    array = ['cas', 'Lorem', '0', '600']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + ARGUMENT_ERROR)
  end

  it 'Checks that cas command received is exceeding an argument' do
    array = ['cas', 'Lorem', '0', '600', '5', '5', 'noreply', '8']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + ARGUMENT_ERROR)
  end

  it 'Checks that \'noreply\' argument is incorrect' do
    array = ['cas', 'Lorem', '0', '600', '5', '5', 'norelpy']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + NOREPLY_ERROR + LINE_BREAK)
  end

  it 'Checks that bytes size and length of data differ' do
    array = ['set', 'Lorem', '0', '600', '4']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + LINE_BREAK)
  end

  it 'Checks that expiration time is invalid (negative value)' do
    array = ['set', 'Lorem', '0', '-1', '5']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + TIME_ERROR + LINE_BREAK)
  end

  it 'Checks that expiration time is invalid (exceeds limit)' do
    array = ['set', 'Lorem', '0', '2592001', '5']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + TIME_ERROR + LINE_BREAK)
  end

  it 'Checks that bytes size is invalid (exceeds limit)' do
    array = ['set', 'Lorem', '0', '600', '257']
    result = validator.command_checker_storage(array, data_long)
    expect(result).to eq(CLIENT_ERROR + BYTES_ERROR + LINE_BREAK)
  end

  it 'Checks that flag value entered is invalid (inferior limit)' do
    array = ['set', 'Lorem', '-65537', '600', '5']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + FLAG_ERROR + LINE_BREAK)
  end

  it 'Checks that flag value entered is invalid (superior limit)' do
    array = ['set', 'Lorem', '65537', '600', '5']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + FLAG_ERROR + LINE_BREAK)
  end

  it 'Checks that bytes size and length of data differ & expiration time is invalid' do
    array = ['set', 'Lorem', '0', '-1', '4']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + TIME_ERROR + LINE_BREAK)
  end

  it 'Checks that bytes size and length of data differ & bytes size is invalid' do
    array = ['set', 'Lorem', '0', '600', '300']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + BYTES_ERROR + LINE_BREAK)
  end

  it 'Checks that bytes size and length of data differ & flag value entered is invalid' do
    array = ['set', 'Lorem', '65537', '600', '4']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + FLAG_ERROR + LINE_BREAK)
  end

  it 'Checks that expiration time & bytes size are invalid' do
    array = ['set', 'Lorem', '0', '-1', '257']
    result = validator.command_checker_storage(array, data_long)
    expect(result).to eq(CLIENT_ERROR + TIME_ERROR + BYTES_ERROR + LINE_BREAK)
  end

  it 'Checks that expiration time & flag value entered are invalid' do
    array = ['set', 'Lorem', '65537', '-1', '5']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + TIME_ERROR + FLAG_ERROR + LINE_BREAK)
  end

  it 'Checks that the bytes size & flag value entered are invalid' do
    array = ['set', 'Lorem', '65537', '600', '257']
    result = validator.command_checker_storage(array, data_long)
    expect(result).to eq(CLIENT_ERROR + BYTES_ERROR + FLAG_ERROR + LINE_BREAK)
  end

  it 'Checks that bytes size and length of data differ & expiration time & bytes size are invalid' do
    array = ['set', 'Lorem', '0', '-1', '258']
    result = validator.command_checker_storage(array, data_long)
    expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + TIME_ERROR + BYTES_ERROR + LINE_BREAK)
  end

  it 'Checks that bytes size and length of data differ & expiration time & flag value entered are invalid' do
    array = ['set', 'Lorem', '65537', '-1', '4']
    result = validator.command_checker_storage(array, data)
    expect(result).to eq(CLIENT_ERROR + MISMATCH_ERROR + TIME_ERROR + FLAG_ERROR + LINE_BREAK)
  end

  it 'Checks that expiration time & bytes size & flag value entered are invalid' do
    array = ['set', 'Lorem', '65537', '-1', '257']
    result = validator.command_checker_storage(array, data_long)
    expect(result).to eq(CLIENT_ERROR + TIME_ERROR + BYTES_ERROR + FLAG_ERROR + LINE_BREAK)
  end

  it 'Checks that every possible input contains an error' do
    array = ['set', 'Lorem', '65537', '-1', '258', 'norelpy']
    result = validator.command_checker_storage(array, data_long)
    expect(result).to eq(CLIENT_ERROR + NOREPLY_ERROR + MISMATCH_ERROR + TIME_ERROR + BYTES_ERROR + FLAG_ERROR + LINE_BREAK)
  end

  it 'Checks time conversion is correct when = 0' do
    result = validator.time_converter(0)
    expect(result).to eq 0
  end

  it 'Checks responds line break if noreply is present' do
    array = ['set', 'Lorem', '0', '600', '5', 'noreply']
    result = validator.has_noreply(array)
    expect(result).to eq LINE_BREAK
  end

  it 'Checks responds Stored if noreply is not present' do
    array = ['set', 'Lorem', '0', '600', '5']
    result = validator.has_noreply(array)
    expect(result).to eq STORED
  end

  it 'should update key flag' do
    array = ['set', 'Lorem', '0', '600', '5']
    command_dao.set(array, data)
    array2 = ['append', 'Lorem', '8', '600', '5']
    validator.update_modified_attributes(array2,command_dao.data_hash)
    key = command_dao.data_hash['Lorem']
    expect(key.flag).to eq 8
  end

  it 'should update key bytes' do
    array = ['set', 'Lorem', '0', '600', '5']
    command_dao.set(array, data)
    array2 = ['append', 'Lorem', '8', '500', '4']
    validator.update_modified_attributes(array2,command_dao.data_hash)
    key = command_dao.data_hash['Lorem']
    expect(key.bytes).to eq 9
  end

  it 'should update key cas value' do
    array = ['set', 'Lorem', '0', '600', '5']
    command_dao.set(array, data)
    array2 = ['append', 'Lorem', '8', '500', '4']
    validator.update_modified_attributes(array2,command_dao.data_hash)
    key = command_dao.data_hash['Lorem']
    expect(key.cas_value).to eq 2
  end

end