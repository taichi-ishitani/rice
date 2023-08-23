module rice_core_alu
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input   var [XLEN-1:0]              i_pc,
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
    operand_1 = get_operand_1(i_alu_operation.source_1, i_rs1_value, i_pc);
    operand_2 = get_operand_2(i_alu_operation.source_2, i_rs2_value, i_imm_value);
  end

  function automatic logic [XLEN-1:0] get_operand_1(
    rice_core_alu_source  source,
    logic [XLEN-1:0]      rs1_value,
    logic [XLEN-1:0]      pc
  );
    case (source)
      RICE_CORE_ALU_SOURCE_RS:  return rs1_value;
      RICE_CORE_ALU_SOURCE_PC:  return pc;
      default:                  return '0;
    endcase
  endfunction

  function automatic logic [XLEN-1:0] get_operand_2(
    rice_core_alu_source  source,
    logic [XLEN-1:0]      rs2_value,
    logic [XLEN-1:0]      imm_value
  );
    case (source)
      RICE_CORE_ALU_SOURCE_RS:    return rs2_value;
      RICE_CORE_ALU_SOURCE_IMM:   return imm_value;
      RICE_CORE_ALU_SOURCE_IMM_4: return XLEN'(4);
      default:                    return '0;
    endcase
  endfunction

//--------------------------------------------------------------
//  ALU
//--------------------------------------------------------------
  always_comb begin
    case (i_alu_operation.command)
      RICE_CORE_ALU_SRA,
      RICE_CORE_ALU_SRL,
      RICE_CORE_ALU_SLL:  o_result  = do_shift(i_alu_operation.command, operand_1, operand_2);
      RICE_CORE_ALU_AND:  o_result  = operand_1 & operand_2;
      RICE_CORE_ALU_OR:   o_result  = operand_1 | operand_2;
      RICE_CORE_ALU_XOR:  o_result  = operand_1 ^ operand_2;
      RICE_CORE_ALU_LT,
      RICE_CORE_ALU_LTU:  o_result  = do_lt(i_alu_operation.command, operand_1, operand_2);
      RICE_CORE_ALU_SUB:  o_result  = operand_1 - operand_2;
      default:            o_result  = operand_1 + operand_2;
    endcase
  end

  function automatic logic [XLEN-1:0] do_shift(
    rice_core_alu_command command,
    logic [XLEN-1:0]      operand_1,
    logic [XLEN-1:0]      operand_2
  );
    logic [2*XLEN-1:0]  data;
    logic [4:0]         size;
    logic [XLEN-1:0]    result;

    case (command)
      RICE_CORE_ALU_SLL: begin
        data[1*XLEN+:XLEN]  = '0;
        data[0*XLEN+:XLEN]  = {<<{operand_1}};
      end
      RICE_CORE_ALU_SRL: begin
        data[1*XLEN+:XLEN]  = '0;
        data[0*XLEN+:XLEN]  = operand_1;
      end
      default: begin
        data[1*XLEN+:XLEN]  = {XLEN{operand_1[XLEN-1]}};
        data[0*XLEN+:XLEN]  = operand_1;
      end
    endcase

    if (XLEN == 32) begin
      result  = data[5'(operand_2)+:XLEN];
    end
    else begin
      result  = data[6'(operand_2)+:XLEN];
    end

    if (command == RICE_CORE_ALU_SLL) begin
      return {<<{result}};
    end
    else begin
      return result;
    end
  endfunction

  function automatic logic [XLEN-1:0] do_lt(
    rice_core_alu_command command,
    logic [XLEN-1:0]      operand_1,
    logic [XLEN-1:0]      operand_2
  );
    logic signed  [XLEN:0]  lhs;
    logic signed  [XLEN:0]  rhs;

    if (command == RICE_CORE_ALU_LT) begin
      lhs = {operand_1[XLEN-1], operand_1};
      rhs = {operand_2[XLEN-1], operand_2};
    end
    else begin
      lhs = {1'b0, operand_1};
      rhs = {1'b0, operand_2};
    end

    return XLEN'(lhs < rhs);
  endfunction
endmodule
