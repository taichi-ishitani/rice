# frozen_string_literal: true

XLEN = ENV['XLEN'].to_i
WORD_SIZE = XLEN / 8
BYTE_SIZE = 4096 * WORD_SIZE

def byte_address(word_address)
  word_address * WORD_SIZE
end
