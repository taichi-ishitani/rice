module rice_core_id_stage
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input var                       i_clk,
  input var                       i_rst_n,
  input var                       i_enable,
  rice_core_pipeline_if.id_stage  pipeline_if
);
  `rice_core_define_types(XLEN)

//--------------------------------------------------------------
//  Decoder
//--------------------------------------------------------------
  rice_core_if_result if_result;
  rice_core_id_result id_result;

  always_comb begin
    pipeline_if.id_result = id_result;
  end

  always_comb begin
    if_result = pipeline_if.if_result;
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      id_result <= rice_core_id_result'(0);
    end
    else if (pipeline_if.flush || (!i_enable)) begin
      id_result <= rice_core_id_result'(0);
    end
    else if (!pipeline_if.stall) begin
      id_result.valid <= if_result.valid;
      if (if_result.valid) begin
        id_result.pc                <= if_result.pc;
        id_result.rs1               <= decode_rs1(if_result.inst);
        id_result.rs2               <= decode_rs2(if_result.inst);
        id_result.rd                <= decode_rd(if_result.inst);
        id_result.rs1_value         <= get_rs1_value(if_result.inst, pipeline_if.register_file);
        id_result.rs2_value         <= get_rs2_value(if_result.inst, pipeline_if.register_file);
        id_result.imm_value         <= get_imm_value(if_result.inst);
        id_result.alu_operation     <= decode_alu_operation(if_result.inst);
        id_result.jamp_operation    <= decode_jamp_operation(if_result.inst);
        id_result.branch_operation  <= decode_branch_operation(if_result.inst);
        id_result.memory_access     <= decode_memory_access(if_result.inst);
      end
    end
  end

  function automatic rice_core_rs decode_rs1(rice_core_inst inst_bits);
    rice_core_inst_r_type inst;
    rice_core_inst_type   inst_type;
    inst      = rice_core_inst_r_type'(inst_bits);
    inst_type = get_inst_type(inst.opcode);
    case (inst_type)
      RICE_CORE_INST_TYPE_U,
      RICE_CORE_INST_TYPE_J:  return rice_core_rs'(0);
      default:                return inst.rs1;
    endcase
  endfunction

  function automatic rice_core_rs decode_rs2(rice_core_inst inst_bits);
    rice_core_inst_r_type inst;
    rice_core_inst_type   inst_type;
    inst      = rice_core_inst_r_type'(inst_bits);
    inst_type = get_inst_type(inst.opcode);
    case (inst_type)
      RICE_CORE_INST_TYPE_I,
      RICE_CORE_INST_TYPE_U,
      RICE_CORE_INST_TYPE_J:  return rice_core_rs'(0);
      default:                return inst.rs2;
    endcase
  endfunction

  function automatic rice_core_rd decode_rd(rice_core_inst inst_bits);
    rice_core_inst_r_type inst;
    rice_core_inst_type   inst_type;
    inst      = rice_core_inst_r_type'(inst_bits);
    inst_type = get_inst_type(inst.opcode);
    case (inst_type)
      RICE_CORE_INST_TYPE_S,
      RICE_CORE_INST_TYPE_B:  return rice_core_rd'(0);
      default:                return inst.rd;
    endcase
  endfunction

  function automatic rice_core_value get_rs1_value(
    rice_core_inst          inst_bits,
    rice_core_value [31:0]  register_file
  );
    rice_core_inst_r_type inst;
    inst  = rice_core_inst_r_type'(inst_bits);
    return register_file[inst.rs1];
  endfunction

  function automatic rice_core_value get_rs2_value(
    rice_core_inst          inst_bits,
    rice_core_value [31:0]  register_file
  );
    rice_core_inst_r_type inst;
    inst  = rice_core_inst_r_type'(inst_bits);
    return register_file[inst.rs2];
  endfunction

  function automatic rice_core_value get_imm_value(
    rice_core_inst  inst_bits
  );
    rice_core_inst_i_type inst_i;
    rice_core_inst_s_type inst_s;
    rice_core_inst_b_type inst_b;
    rice_core_inst_u_type inst_u;
    rice_core_inst_j_type inst_j;
    rice_core_inst_type   inst_type;

    inst_i    = rice_core_inst_i_type'(inst_bits);
    inst_s    = rice_core_inst_s_type'(inst_bits);
    inst_b    = rice_core_inst_b_type'(inst_bits);
    inst_u    = rice_core_inst_u_type'(inst_bits);
    inst_j    = rice_core_inst_j_type'(inst_bits);
    inst_type = get_inst_type(inst_i.opcode);
    case (inst_type)
      RICE_CORE_INST_TYPE_I:
        return {{(XLEN-11){inst_i.imm_11}}, inst_i.imm_10_0};
      RICE_CORE_INST_TYPE_S:
        return {{(XLEN-11){inst_s.imm_11}}, inst_s.imm_10_5, inst_s.imm_4_0};
      RICE_CORE_INST_TYPE_B:
        return {{(XLEN-12){inst_b.imm_12}}, inst_b.imm_11, inst_b.imm_10_5, inst_b.imm_4_1, 1'(0)};
      RICE_CORE_INST_TYPE_U:
        return {{(XLEN-31){inst_u.imm_31}}, inst_u.imm_30_12, 12'(0)};
      default:
        return {{(XLEN-20){inst_j.imm_20}}, inst_j.imm_19_12, inst_j.imm_11, inst_j.imm_10_1, 1'(0)};
    endcase
  endfunction

  function automatic rice_core_alu_operation get_alu_operation(
    rice_core_alu_command command,
    rice_core_alu_source  source_1,
    rice_core_alu_source  source_2
  );
    rice_core_alu_operation operation;
    operation.command   = command;
    operation.source_1  = source_1;
    operation.source_2  = source_2;
    return operation;
  endfunction

  function automatic rice_core_alu_operation decode_alu_operation(rice_core_inst inst_bits);
    rice_core_inst_r_type   inst;

    inst  = rice_core_inst_r_type'(inst_bits);
    case ({inst.opcode, inst.funct3, inst.funct7}) inside
      {RICE_CORE_OPCODE_LUI, 3'b???, 7'b???_????}:    //  lui
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_IMM_0, RICE_CORE_ALU_SOURCE_IMM);
      {RICE_CORE_OPCODE_AUIPC, 3'b???, 7'b???_????}:  //  auipc
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_PC, RICE_CORE_ALU_SOURCE_IMM);
      {RICE_CORE_OPCODE_JAL, 3'b???, 7'b???_????}:    //  jal
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_PC, RICE_CORE_ALU_SOURCE_IMM_4);
      {RICE_CORE_OPCODE_JALR, 3'b000, 7'b???_????}:   //  jalr
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_PC, RICE_CORE_ALU_SOURCE_IMM_4);
      {RICE_CORE_OPCODE_BRANCH, 3'b000, 7'b???_????}: //  beq
        return get_alu_operation(RICE_CORE_ALU_XOR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_BRANCH, 3'b001, 7'b???_????}: //  bne
        return get_alu_operation(RICE_CORE_ALU_XOR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_BRANCH, 3'b100, 7'b???_????}: //  blt
        return get_alu_operation(RICE_CORE_ALU_LT, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_BRANCH, 3'b101, 7'b???_????}: //  bge
        return get_alu_operation(RICE_CORE_ALU_LT, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_BRANCH, 3'b110, 7'b???_????}: //  bltu
        return get_alu_operation(RICE_CORE_ALU_LTU, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_BRANCH, 3'b111, 7'b???_????}: //  bgeu
        return get_alu_operation(RICE_CORE_ALU_LTU, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_OP_IMM, 3'b000, 7'b???_????}: //  addi
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      {RICE_CORE_OPCODE_OP_IMM, 3'b010, 7'b???_????}: //  slti
        return get_alu_operation(RICE_CORE_ALU_LT, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      {RICE_CORE_OPCODE_OP_IMM, 3'b011, 7'b???_????}: //  sltiu
        return get_alu_operation(RICE_CORE_ALU_LTU, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      {RICE_CORE_OPCODE_OP_IMM, 3'b100, 7'b???_????}: //  xori
        return get_alu_operation(RICE_CORE_ALU_XOR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      {RICE_CORE_OPCODE_OP_IMM, 3'b110, 7'b???_????}: //  ori
        return get_alu_operation(RICE_CORE_ALU_OR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      {RICE_CORE_OPCODE_OP_IMM, 3'b111, 7'b???_????}: //  andi
        return get_alu_operation(RICE_CORE_ALU_AND, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      {RICE_CORE_OPCODE_OP_IMM, 3'b001, 7'b000_0000}: //  slli
        return get_alu_operation(RICE_CORE_ALU_SLL, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      {RICE_CORE_OPCODE_OP_IMM, 3'b101, 7'b000_0000}: //  srli
        return get_alu_operation(RICE_CORE_ALU_SRL, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      {RICE_CORE_OPCODE_OP_IMM, 3'b101, 7'b010_0000}: //  srai
        return get_alu_operation(RICE_CORE_ALU_SRA, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      {RICE_CORE_OPCODE_OP, 3'b000, 7'b000_0000}:     //  add
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_OP, 3'b000, 7'b010_0000}:     //  sub
        return get_alu_operation(RICE_CORE_ALU_SUB, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_OP, 3'b010, 7'b000_0000}:     //  slt
        return get_alu_operation(RICE_CORE_ALU_LT, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_OP, 3'b011, 7'b000_0000}:     //  sltu
        return get_alu_operation(RICE_CORE_ALU_LTU, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_OP, 3'b100, 7'b000_0000}:     //  xor
        return get_alu_operation(RICE_CORE_ALU_XOR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_OP, 3'b110, 7'b000_0000}:     //  or
        return get_alu_operation(RICE_CORE_ALU_OR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_OP, 3'b111, 7'b000_0000}:     //  and
        return get_alu_operation(RICE_CORE_ALU_AND, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_OP, 3'b001, 7'b000_0000}:     //  sll
        return get_alu_operation(RICE_CORE_ALU_SLL, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_OP, 3'b101, 7'b000_0000}:     //  srl
        return get_alu_operation(RICE_CORE_ALU_SRL, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      {RICE_CORE_OPCODE_OP, 3'b101, 7'b010_0000}:     //  sra
        return get_alu_operation(RICE_CORE_ALU_SRA, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      default:
        return get_alu_operation(RICE_CORE_ALU_NONE, RICE_CORE_ALU_SOURCE_IMM_0, RICE_CORE_ALU_SOURCE_IMM_0);
    endcase
  endfunction

  function automatic rice_core_jamp_operation decode_jamp_operation(rice_core_inst inst_bits);
    rice_core_inst_i_type     inst;
    rice_core_jamp_operation  jamp_operation;
    inst                = rice_core_inst_i_type'(inst_bits);
    jamp_operation.jal  = (inst.opcode == RICE_CORE_OPCODE_JAL );
    jamp_operation.jalr = (inst.opcode == RICE_CORE_OPCODE_JALR) && (inst.funct3 == 3'b000);
    return jamp_operation;
  endfunction

  function automatic rice_core_branch_operation decode_branch_operation(rice_core_inst inst_bits);
    rice_core_inst_b_type       inst;
    rice_core_branch_operation  branch_operation;

    inst  = rice_core_inst_b_type'(inst_bits);
    branch_operation.eq_ge  =
      (inst.opcode == RICE_CORE_OPCODE_BRANCH) &&
      (inst.funct3 inside {3'b000, 3'b101, 3'b111});
    branch_operation.ne_lt  =
      (inst.opcode == RICE_CORE_OPCODE_BRANCH) &&
      (inst.funct3 inside {3'b001, 3'b100, 3'b110});

    return branch_operation;
  endfunction

  function automatic rice_core_memory_access decode_memory_access(rice_core_inst inst_bits);
    rice_core_inst_r_type   inst;
    rice_core_memory_access memory_access;

    inst  = rice_core_inst_r_type'(inst_bits);
    case (inst.opcode)
      RICE_CORE_OPCODE_LOAD:  memory_access.access_type = RICE_CORE_MEMORY_ACCESS_LOAD;
      RICE_CORE_OPCODE_STORE: memory_access.access_type = RICE_CORE_MEMORY_ACCESS_STORE;
      default:                memory_access.access_type = RICE_CORE_MEMORY_ACCESS_NONE;
    endcase

    memory_access.access_mode = rice_core_memory_access_mode'(inst.funct3);

    return memory_access;
  endfunction

//--------------------------------------------------------------
//  Debug
//--------------------------------------------------------------
  if (RICE_CORE_DEBUG) begin : g_debug
    rice_core_inst_r_type inst_r_type;
    rice_core_inst_i_type inst_i_type;
    rice_core_inst_s_type inst_s_type;
    rice_core_inst_b_type inst_b_type;
    rice_core_inst_u_type inst_u_type;
    rice_core_inst_j_type inst_j_type;

    always_comb begin
      inst_r_type = rice_core_inst_r_type'(if_result.inst);
      inst_i_type = rice_core_inst_i_type'(if_result.inst);
      inst_s_type = rice_core_inst_s_type'(if_result.inst);
      inst_b_type = rice_core_inst_b_type'(if_result.inst);
      inst_u_type = rice_core_inst_u_type'(if_result.inst);
      inst_j_type = rice_core_inst_j_type'(if_result.inst);
    end
  end
endmodule
