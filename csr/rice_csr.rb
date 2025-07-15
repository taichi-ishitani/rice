# frozen_string_literal: true

class << self
  def xlen
    configuration.bus_width
  end

  def word_size
    @word_size ||= xlen / 8
  end

  def block_size
    @block_size ||= word_size * 4096
  end

  def byte_address(address)
    address * word_size
  end
end

register_block {
  name "rice_csr_xlen#{xlen}"
  byte_size block_size

#==============================================================
# Machine level registrers
#==============================================================
  #
  # Machine Information Registers
  #
  register {
    name 'mvendorid'
    offset_address byte_address(0xF11)
    bit_field {
      bit_assignment lsb: 0, width: 32; type :rof; initial_value 0
    }
  }

  register {
    name 'marchid'
    offset_address byte_address(0xF12)
    bit_field {
      bit_assignment lsb: 0, width: xlen; type :rof; initial_value default: 0
    }
  }

  register {
    name 'mimpid'
    offset_address byte_address(0xF13)
    bit_field {
      bit_assignment lsb: 0, width: xlen; type :rof; initial_value default: 0
    }
  }

  register {
    name 'mhartid'
    offset_address byte_address(0xF14)
    bit_field {
      bit_assignment lsb: 0, width: xlen; type :ro
    }
  }

  #
  # Machine Trap Setup
  #
  register {
    name 'mstatus'
    offset_address byte_address(0x300)
    bit_field {
      name 'sie'
      bit_assignment lsb: 1, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'mie'
      bit_assignment lsb: 3, width: 1; type :rwhw; initial_value 0
    }
    bit_field {
      name 'spie'
      bit_assignment lsb: 5, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'ube'
      bit_assignment lsb: 6, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'mpie'
      bit_assignment lsb: 7, width: 1; type :rwhw; initial_value 0
    }
    bit_field {
      name 'spp'
      bit_assignment lsb: 8, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'vs'
      bit_assignment lsb: 9, width: 2; type :rof; initial_value 0
    }
    bit_field {
      name 'mpp'
      bit_assignment lsb: 11, width: 2; type :rwhw; initial_value 0
    }
    bit_field {
      name 'fs'
      bit_assignment lsb: 13, width: 2; type :rof; initial_value 0
    }
    bit_field {
      name 'xs'
      bit_assignment lsb: 15, width: 2; type :rof; initial_value 0
    }
    bit_field {
      name 'mprv'
      bit_assignment lsb: 17, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'sum'
      bit_assignment lsb: 18, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'mxr'
      bit_assignment lsb: 19, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'tvm'
      bit_assignment lsb: 20, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'tw'
      bit_assignment lsb: 21, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'tsr'
      bit_assignment lsb: 22, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'sd'
      bit_assignment lsb: xlen - 1, width: 1; type :rof; initial_value 0
    }
  }

  register {
    name 'misa'
    offset_address byte_address(0x301)
    type :rw
    bit_field {
      name 'support_e'
      bit_assignment lsb: 4, width: 1; type :ro; reference 'misa.support_i'
    }
    bit_field {
      name 'support_i'
      bit_assignment lsb: 8, width: 1; type :rof; initial_value 1
    }
    bit_field {
      name 'support_m'
      bit_assignment lsb: 12, width: 1; type :rof; initial_value 1
    }
    bit_field {
      name 'user_mode'
      bit_assignment lsb: 20, width: 1; type :rof; initial_value 1
    }
    bit_field {
      name 'mxl'
      bit_assignment lsb: xlen - 2, width: 2; type :rof
      initial_value case xlen
                    when 32 then 0b01
                    else 0b00
                    end
    }
  }

  register {
    name 'mie'
    offset_address byte_address(0x304)
    type :rw
    bit_field {
      name 'ssie'
      bit_assignment lsb: 1, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'msie'
      bit_assignment lsb: 3, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'stie'
      bit_assignment lsb: 5, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'mtie'
      bit_assignment lsb: 7, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'seie'
      bit_assignment lsb: 9, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'meie'
      bit_assignment lsb: 11, width: 1; type :rof; initial_value 0
    }
  }

  register {
    name 'mtvec'
    offset_address byte_address(0x305)
    bit_field {
      name 'mode'
      bit_assignment lsb: 0, width: 1; type :rw; initial_value 0
    }
    bit_field {
      name 'base'
      bit_assignment lsb: 2, width: xlen - 2; type :rw; initial_value 0
    }
  }

  register {
    name 'mcounteren'
    offset_address byte_address(0x306)
    bit_field {
      name 'cy'
      bit_assignment lsb: 0, width: 1; type :rw; initial_value 0
    }
    bit_field {
      name 'ir'
      bit_assignment lsb: 2, width: 1; type :rw; initial_value 0
    }
  }

  if xlen == 32
    register {
      name 'mstatush'
      offset_address byte_address(0x310)
      type :rw
      bit_field {
        name 'sbe'
        bit_assignment lsb: 4, width: 1; type :rof; initial_value 0
      }
      bit_field {
        name 'mbe'
        bit_assignment lsb: 5, width: 1; type :rof; initial_value 0
      }
    }
  end

  #
  # Machine Trap Handling
  #
  register {
    name 'mscratch'
    offset_address byte_address(0x340)
    bit_field {
      bit_assignment lsb: 0, width: xlen; type :rw; initial_value 0
    }
  }

  register {
    name 'mepc'
    offset_address byte_address(0x341)
    bit_field {
      bit_assignment lsb: 0, width: xlen; type :rwhw; initial_value 0
    }
  }

  register {
    name 'mcause'
    offset_address byte_address(0x342)
    bit_field {
      name 'exception_code'
      bit_assignment lsb: 0, width: xlen - 1; type :rwhw; initial_value 0
    }
    bit_field {
      name 'interrupt'
      bit_assignment lsb: xlen - 1, width: 1; type :rwhw; initial_value 0
    }
  }

  register {
    name 'mtval'
    offset_address byte_address(0x343)
    bit_field {
      bit_assignment lsb: 0, width: xlen; type :rwhw; initial_value 0
    }
  }

  register {
    name 'mip'
    offset_address byte_address(0x344)
    bit_field {
      name 'ssip'
      bit_assignment lsb: 1, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'msip'
      bit_assignment lsb: 3, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'stip'
      bit_assignment lsb: 5, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'mtip'
      bit_assignment lsb: 7, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'seip'
      bit_assignment lsb: 9, width: 1; type :rof; initial_value 0
    }
    bit_field {
      name 'meip'
      bit_assignment lsb: 11, width: 1; type :rof; initial_value 0
    }
  }

  #
  # Machine Counter/Timers
  #
  register {
    name 'mcycle'
    offset_address byte_address(0xB00)
    bit_field {
      bit_assignment lsb: 0, width: xlen; type :counter; initial_value 0
      reference 'mcountinhibit.cy'
    }
  }

  register {
    name 'minstret'
    offset_address byte_address(0xB02)
    bit_field {
      bit_assignment lsb: 0, width: xlen; type :counter; initial_value 0
      reference 'mcountinhibit.ir'
    }
  }

  if xlen == 32
    register {
      name 'mcycleh'
      offset_address byte_address(0xB80)
      bit_field {
        bit_assignment lsb: 0, width: xlen; type :counter; initial_value 0
        reference 'mcountinhibit.cy'
      }
    }

    register {
      name 'minstreth'
      offset_address byte_address(0xB82)
      bit_field {
        bit_assignment lsb: 0, width: xlen; type :counter; initial_value 0
        reference 'mcountinhibit.ir'
      }
    }
  end

  #
  # Machine Counter Setup
  #
  register {
    name 'mcountinhibit'
    offset_address byte_address(0x320)
    bit_field {
      name 'cy'
      bit_assignment lsb: 0, width: 1; type :rw; initial_value 0
    }
    bit_field {
      name 'ir'
      bit_assignment lsb: 2, width: 1; type :rw; initial_value 0
    }
  }

#==============================================================
# User level registrers
#==============================================================
  #
  # Unprivileged Counter/Timers
  #
  register {
    name 'cycle'
    offset_address byte_address(0xC00)
    type :variable_access
    bit_field {
      bit_assignment lsb: 0, width: xlen; type :ro
    }
  }

  register {
    name 'instret'
    offset_address byte_address(0xC02)
    type :variable_access
    bit_field {
      bit_assignment lsb: 0, width: xlen; type :ro
    }
  }

  if xlen == 32
    register {
      name 'cycleh'
      offset_address byte_address(0xC80)
      type :variable_access
      bit_field {
        bit_assignment lsb: 0, width: xlen; type :ro
      }
    }

    register {
      name 'instreth'
      offset_address byte_address(0xC82)
      type :variable_access
      bit_field {
        bit_assignment lsb: 0, width: xlen; type :ro
      }
    }
  end
}
