# frozen_string_literal: true
LINE_BREAK = "\r\n"
CLIENT_ERROR = 'CLIENT_ERROR'
ARGUMENT_ERROR = " - Invalid command, check for missing/exceding arguments\r\n"
MISMATCH_ERROR = ' - Bytes and length of data block do not match'
TIME_ERROR = ' - Invalid expiration time'
BYTES_ERROR = ' - Invalid bytes size'
FLAG_ERROR = ' - Inavlid flag'
NOREPLY_ERROR = ' - Invalid \'noreply\' value'
ERROR = "ERROR\r\n"
SUCCESS = 'success'
EXISTS = "EXISTS\r\n"
STORED = "STORED\r\n"
NOT_FOUND = "NOT_FOUND\r\n"
NOT_STORED = "NOT_STORED\r\n"
END_MESSAGE = "END\r\n"
INSTRUCTIONS = "\r\nIn order to interact with the server, there are 'storage' and 'retrieval' commands.\r\n\r\n" \
  "The storage commands require this format:\r\n\r\n" \
  "   <command name> <key> <flags> <exptime> <bytes> (<cas value> only for cas command) *Press the enter key*\r\n" \
  "   <data block>\r\n\r\n" \
  "Available storage commands:\r\n\r\n" \
  "   -'set' means 'store this data'.\r\n" \
  "   -'add' means 'store this data, but only if the server *doesn't* already hold data for this key'\r\n" \
  "   -'replace' means 'store this data, but only if the server *does* already hold data for this key'\r\n" \
  "   -'append' means 'add this data to an existing key after existing data'\r\n" \
  "   -'prepend' means 'add this data to an existing key before existing data'\r\n" \
  "   -'cas' means 'store this data but only if no one else has updated since I last fetched it.'\r\n\r\n\r\n" \
  "The retrieval commands require this format:\r\n\r\n" \
  "   <command name> <key>*\r\n\r\n" \
  "Available retrieval commands:\r\n\r\n" \
  "   -'get' retrieves the key, flag, bytes and value information in this way:\r\n" \
  "       VALUE <key> <flags> <bytes>\r\n" \
  "       <data block>\r\n\r\n" \
  "   -'gets' retrieves the key, flag, bytes, cas value and value information in this way:\r\n" \
  "       VALUE <key> <flags> <bytes> <cas value>\r\n" \
  "       <data block>\r\n\r\n" \
  "Try setting your first block by typing:\r\n\r\n" \
  "set Marco 0 600 4 *Press the enter key*\r\n" \
  "Polo\r\n\r\n"
