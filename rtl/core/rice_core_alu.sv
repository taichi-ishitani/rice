module rice_core_alu
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input   var [XLEN-1:0]              i_rs1_value,
  input   var [XLEN-1:0]              i_rs2_value,
  input   var [XLEN-1:0]              i_imm_value,
  input   var rice_core_alu_operation i_alu_operation,
  output  var [XLEN-1:0]              o_result
);
//--------------------------------------------------------------
//  Operand selection
//--------------------------------------------------------------
  logic [XLEN-1:0]  operand_1;
  logic [XLEN-1:0]  operand_2;

  always_comb begin
    operand_1 = get_operand_1(i_alu_operation.source_1, i_rs1_value);
    operand_2 = get_operand_2(i_alu_operation.source_2, i_rs2_value, i_imm_value);
  end

  function automatic logic [XLEN-1:0] get_operand_1(
    rice_core_alu_source  source,
    logic [XLEN-1:0]      rs1_value
  );
    case (source)
      RICE_CORE_ALU_SOURCE_RS:  return rs1_value;
      default:                  return '0;
    endcase
  endfunction

  function automatic logic [XLEN-1:0] get_operand_2(
    rice_core_alu_source  source,
    logic [XLEN-1:0]      rs2_value,
    logic [XLEN-1:0]      imm_value
  );
    case (source)
      RICE_CORE_ALU_SOURCE_RS:  return rs2_value;
      RICE_CORE_ALU_SOURCE_IMM: return imm_value;
      default:                  return '0;
    endcase
  endfunction

//--------------------------------------------------------------
//  ALU
//--------------------------------------------------------------
  always_comb begin
    case (i_alu_operation.command)
      RICE_CORE_ALU_SUB:  o_result  = operand_1 - operand_2;
      default:            o_result  = operand_1 + operand_2;
    endcase
  end
endmodule
