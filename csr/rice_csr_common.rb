# frozen_string_literal: true

def setup(register_map)
  m = Module.new do
    def xlen
      @xlen ||= configuration.bus_width
    end

    def word_size
      @word_size ||= (xlen / 8)
    end

    def block_size
      @block_size ||= (4096 * word_size)
    end

    def byte_address(word_address)
      word_address * word_size
    end
  end
  register_map.extend(m)
end
