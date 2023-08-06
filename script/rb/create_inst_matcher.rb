require 'yaml'

def matcher_definition(op_name, pattern)
  patterns =
    case pattern['type']
    when 'r' then bit_pattern_r_type(pattern)
    when 'i' then bit_pattern_i_type(pattern)
    when 's' then bit_pattern_s_type(pattern)
    when 'b' then bit_pattern_b_type(pattern)
    when 'u' then bit_pattern_u_type(pattern)
    when 'j' then bit_pattern_j_type(pattern)
    end

  opcode = "RICE_RISCV_OPCODE_#{pattern['opcode'].upcase}"
  bit_pattern = sprintf('25\'b%s', patterns.reverse.join)

  sprintf(<<~F, op_name, bit_pattern, opcode)
    function automatic logic match_%s(rice_riscv_inst inst_bits);
      return inst_bits ==? {%s, %s};
    endfunction
  F
end

def bit_pattern_r_type(pattern)
  [
    to_bit_pattern(pattern, 'rd', 5),
    to_bit_pattern(pattern, 'funct3', 3),
    to_bit_pattern(pattern, 'rs1', 5),
    to_bit_pattern(pattern, 'rs2', 5),
    to_bit_pattern(pattern, 'funct7', 7)
  ]
end

def bit_pattern_i_type(pattern)
  [
    to_bit_pattern(pattern, 'rd', 5),
    to_bit_pattern(pattern, 'funct3', 3),
    to_bit_pattern(pattern, 'rs1', 5),
    to_bit_pattern(pattern, 'imm', 12)
  ]
end

def bit_pattern_s_type(pattern)
  [
    to_bit_pattern(pattern, 'imm', 5, 0),
    to_bit_pattern(pattern, 'funct3', 3),
    to_bit_pattern(pattern, 'rs1', 5),
    to_bit_pattern(pattern, 'rs2', 5),
    to_bit_pattern(pattern, 'imm', 7, 5)
  ]
end

def bit_pattern_b_type(pattern)
  [
    to_bit_pattern(pattern, 'imm', 1, 11),
    to_bit_pattern(pattern, 'imm', 4, 1),
    to_bit_pattern(pattern, 'funct3', 3),
    to_bit_pattern(pattern, 'rs1', 5),
    to_bit_pattern(pattern, 'rs2', 5),
    to_bit_pattern(pattern, 'imm', 6, 5),
    to_bit_pattern(pattern, 'imm', 1, 12)
  ]
end

def bit_pattern_u_type(pattern)
  [
    to_bit_pattern(pattern, 'rd', 5),
    to_bit_pattern(pattern, 'imm', 20, 12)
  ]
end

def bit_pattern_j_type(pattern)
  [
    to_bit_pattern(pattern, 'rd', 5),
    to_bit_pattern(pattern, 'imm', 8, 12),
    to_bit_pattern(pattern, 'imm', 1, 11),
    to_bit_pattern(pattern, 'imm', 10, 1),
    to_bit_pattern(pattern, 'imm', 1, 20)
  ]
end

def to_bit_pattern(pattern, name, width, lsb = 0)
  value = pattern[name]
  case value
  when String then value
  when Integer then sprintf('%0*b', width, value[lsb, width])
  else 'x' * width
  end
end



inst_definitions = YAML.load_file(ARGV[0])
matchers =
  inst_definitions.map do |op_name, pattern|
    matcher_definition(op_name, pattern)
  end

File.open(ARGV[1], 'w') do |f|
  body = []
  body << 'import  rice_riscv_pkg::*;'
  body << ''
  body.concat(matchers)

  package_body =
    body
      .join("\n")
      .each_line.map { |l| "  #{l}".sub(/^ +$/, '') }
      .join

  f << 'package rice_riscv_inst_matcher_pkg;' << "\n"
  f << package_body
  f << 'endpackage' << "\n"
end
