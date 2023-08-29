# frozen_string_literal: true

require_relative 'rice_csr_common'

register_block {
  name "rice_csr_u_level_xlen#{XLEN}"
  byte_size BYTE_SIZE

  #
  # Unprivileged Counter/Timers
  #
  register {
    name 'cycle'
    offset_address byte_address(0xC00)
    type :variable_access
    bit_field {
      bit_assignment lsb: 0, width: XLEN; type :ro
    }
  }

  register {
    name 'instret'
    offset_address byte_address(0xC02)
    type :variable_access
    bit_field {
      bit_assignment lsb: 0, width: XLEN; type :ro
    }
  }

  if XLEN == 32
    register {
      name 'cycleh'
      offset_address byte_address(0xC80)
      type :variable_access
      bit_field {
        bit_assignment lsb: 0, width: XLEN; type :ro
      }
    }

    register {
      name 'instreth'
      offset_address byte_address(0xC82)
      type :variable_access
      bit_field {
        bit_assignment lsb: 0, width: XLEN; type :ro
      }
    }
  end
}
