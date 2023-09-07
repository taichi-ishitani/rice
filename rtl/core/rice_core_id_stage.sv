module rice_core_id_stage
  import  rice_riscv_pkg::*,
          rice_riscv_inst_matcher_pkg::*,
          rice_core_pkg::*;
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
//  Register file
//--------------------------------------------------------------
  logic [XLEN-1:0]  rf[RICE_RISCV_RF_SIZE];

  always_comb begin
    pipeline_if.rf  = rf;
  end

  rice_core_register_file #(
    .XLEN       (XLEN                 ),
    .EX_RESULT  (rice_core_ex_result  )
  ) u_register_file (
    .i_clk        (i_clk                  ),
    .i_ex_result  (pipeline_if.ex_result  ),
    .o_rf         (rf                     )
  );

//--------------------------------------------------------------
//  Decoder
//--------------------------------------------------------------
  rice_core_if_result if_result;
  rice_core_id_result id_result;

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
        id_result.inst              <= if_result.inst;
        id_result.rs1               <= decode_rs1(if_result.inst);
        id_result.rs2               <= decode_rs2(if_result.inst);
        id_result.rd                <= decode_rd(if_result.inst);
        id_result.rs1_value         <= get_rs1_value(if_result.inst, rf);
        id_result.rs2_value         <= get_rs2_value(if_result.inst, rf);
        id_result.imm_value         <= get_imm_value(if_result.inst);
        id_result.alu_operation     <= decode_alu_operation(if_result.inst);
        id_result.mul_operation     <= decode_mul_operation(if_result.inst);
        id_result.div_operation     <= decode_div_operation(if_result.inst);
        id_result.jamp_operation    <= decode_jamp_operation(if_result.inst);
        id_result.memory_access     <= decode_memory_access(if_result.inst);
        id_result.ordering_control  <= decode_ordering_control(if_result.inst);
        id_result.trap_control      <= decode_trap_control(if_result.inst);
        id_result.csr_access        <= decode_csr_access(if_result.inst);
      end
    end
  end

  function automatic rice_riscv_rs decode_rs1(rice_riscv_inst inst_bits);
    rice_riscv_inst_r_type  inst;
    rice_riscv_inst_type    inst_type;
    inst      = rice_riscv_inst_r_type'(inst_bits);
    inst_type = get_inst_type(inst.opcode);
    case (inst_type)
      RICE_RISCV_INST_TYPE_U,
      RICE_RISCV_INST_TYPE_J: return rice_riscv_rs'(0);
      default:                return inst.rs1;
    endcase
  endfunction

  function automatic rice_riscv_rs decode_rs2(rice_riscv_inst inst_bits);
    rice_riscv_inst_r_type  inst;
    rice_riscv_inst_type    inst_type;
    inst      = rice_riscv_inst_r_type'(inst_bits);
    inst_type = get_inst_type(inst.opcode);
    case (inst_type)
      RICE_RISCV_INST_TYPE_I,
      RICE_RISCV_INST_TYPE_U,
      RICE_RISCV_INST_TYPE_J: return rice_riscv_rs'(0);
      default:                return inst.rs2;
    endcase
  endfunction

  function automatic rice_riscv_rd decode_rd(rice_riscv_inst inst_bits);
    rice_riscv_inst_r_type  inst;
    rice_riscv_inst_type    inst_type;
    inst      = rice_riscv_inst_r_type'(inst_bits);
    inst_type = get_inst_type(inst.opcode);
    case (inst_type)
      RICE_RISCV_INST_TYPE_S,
      RICE_RISCV_INST_TYPE_B: return rice_riscv_rd'(0);
      default:                return inst.rd;
    endcase
  endfunction

  function automatic rice_core_value get_rs1_value(
    rice_riscv_inst inst_bits,
    rice_core_value rf[RICE_RISCV_RF_SIZE]
  );
    rice_riscv_inst_r_type  inst;
    inst  = rice_riscv_inst_r_type'(inst_bits);
    return rf[inst.rs1];
  endfunction

  function automatic rice_core_value get_rs2_value(
    rice_riscv_inst inst_bits,
    rice_core_value rf[RICE_RISCV_RF_SIZE]
  );
    rice_riscv_inst_r_type  inst;
    inst  = rice_riscv_inst_r_type'(inst_bits);
    return rf[inst.rs2];
  endfunction

  function automatic rice_core_value get_imm_value(rice_riscv_inst inst_bits);
    rice_riscv_inst_i_type  inst_i;
    rice_riscv_inst_s_type  inst_s;
    rice_riscv_inst_b_type  inst_b;
    rice_riscv_inst_u_type  inst_u;
    rice_riscv_inst_j_type  inst_j;
    rice_riscv_inst_type    inst_type;

    inst_i    = rice_riscv_inst_i_type'(inst_bits);
    inst_s    = rice_riscv_inst_s_type'(inst_bits);
    inst_b    = rice_riscv_inst_b_type'(inst_bits);
    inst_u    = rice_riscv_inst_u_type'(inst_bits);
    inst_j    = rice_riscv_inst_j_type'(inst_bits);
    inst_type = get_inst_type(inst_i.opcode);
    case (inst_type)
      RICE_RISCV_INST_TYPE_I:
        return {{(XLEN-11){inst_i.imm_11}}, inst_i.imm_10_0};
      RICE_RISCV_INST_TYPE_S:
        return {{(XLEN-11){inst_s.imm_11}}, inst_s.imm_10_5, inst_s.imm_4_0};
      RICE_RISCV_INST_TYPE_B:
        return {{(XLEN-12){inst_b.imm_12}}, inst_b.imm_11, inst_b.imm_10_5, inst_b.imm_4_1, 1'(0)};
      RICE_RISCV_INST_TYPE_U:
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

  function automatic rice_core_alu_operation decode_alu_operation(rice_riscv_inst inst_bits);
    case (1'b1)
      match_lui(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_IMM_0, RICE_CORE_ALU_SOURCE_IMM);
      match_auipc(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_PC, RICE_CORE_ALU_SOURCE_IMM);
      match_jal(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_PC, RICE_CORE_ALU_SOURCE_IMM_4);
      match_jalr(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_PC, RICE_CORE_ALU_SOURCE_IMM_4);
      match_beq(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_XOR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_bne(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_XOR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_blt(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_LT, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_bge(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_LT, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_bltu(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_LTU, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_bgeu(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_LTU, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_addi(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      match_slti(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_LT, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      match_sltiu(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_LTU, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      match_xori(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_XOR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      match_ori(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_OR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      match_andi(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_AND, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      match_slli(inst_bits) && ((XLEN == 64) || (inst_bits[25] == '0)):
        return get_alu_operation(RICE_CORE_ALU_SLL, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      match_srli(inst_bits) && ((XLEN == 64) || (inst_bits[25] == '0)):
        return get_alu_operation(RICE_CORE_ALU_SRL, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      match_srai(inst_bits) && ((XLEN == 64) || (inst_bits[25] == '0)):
        return get_alu_operation(RICE_CORE_ALU_SRA, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      match_add(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_sub(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_SUB, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_sll(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_SLL, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_slt(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_LT, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_sltu(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_LTU, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_xor(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_XOR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_srl(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_SRL, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_sra(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_SRA, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_or(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_OR, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_and(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_AND, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_RS);
      match_fence(inst_bits):
        return get_alu_operation(RICE_CORE_ALU_ADD, RICE_CORE_ALU_SOURCE_RS, RICE_CORE_ALU_SOURCE_IMM);
      default:
        return get_alu_operation(RICE_CORE_ALU_NONE, RICE_CORE_ALU_SOURCE_IMM_0, RICE_CORE_ALU_SOURCE_IMM_0);
    endcase
  endfunction

  function automatic rice_core_mul_operation decode_mul_operation(rice_riscv_inst inst_bits);
    rice_core_mul_operation mul_operation;

    mul_operation.mul     = match_mul(inst_bits);
    mul_operation.mulh    = match_mulh(inst_bits);
    mul_operation.mulhsu  = match_mulhsu(inst_bits);
    mul_operation.mulhu   = match_mulhu(inst_bits);

    return mul_operation;
  endfunction

  function automatic rice_core_div_operation decode_div_operation(rice_riscv_inst inst_bits);
    rice_core_div_operation div_operation;

    div_operation.div   = match_div(inst_bits);
    div_operation.divu  = match_divu(inst_bits);
    div_operation.rem   = match_rem(inst_bits);
    div_operation.remu  = match_remu(inst_bits);

    return div_operation;
  endfunction

  function automatic rice_core_jamp_operation decode_jamp_operation(rice_riscv_inst inst_bits);
    rice_core_jamp_operation  jamp_operation;
    jamp_operation.jal      = match_jal(inst_bits);
    jamp_operation.jalr     = match_jalr(inst_bits);
    jamp_operation.beq_bge  = match_beq(inst_bits) || match_bge(inst_bits) || match_bgeu(inst_bits);
    jamp_operation.bne_blt  = match_bne(inst_bits) || match_blt(inst_bits) || match_bltu(inst_bits);
    return jamp_operation;
  endfunction

  function automatic rice_core_memory_access decode_memory_access(rice_riscv_inst inst_bits);
    rice_riscv_inst_r_type  inst;
    rice_core_memory_access memory_access;

    inst  = rice_riscv_inst_r_type'(inst_bits);
    case (inst.opcode)
      RICE_RISCV_OPCODE_LOAD:   memory_access.access_type = RICE_CORE_MEMORY_ACCESS_LOAD;
      RICE_RISCV_OPCODE_STORE:  memory_access.access_type = RICE_CORE_MEMORY_ACCESS_STORE;
      default:                  memory_access.access_type = RICE_CORE_MEMORY_ACCESS_NONE;
    endcase

    memory_access.access_mode = rice_core_memory_access_mode'(inst.funct3);

    return memory_access;
  endfunction

  function automatic rice_core_ordering_control decode_ordering_control(rice_riscv_inst inst_bits);
    rice_core_ordering_control  ordering_control;
    rice_riscv_inst_i_type      inst;
    inst                      = rice_riscv_inst_i_type'(inst_bits);
    ordering_control.fence_i  = match_fence_i(inst_bits);
    ordering_control.fence    = match_fence(inst_bits);
    ordering_control.succ     = inst.imm_10_0[0+:4];
    ordering_control.pred     = inst.imm_10_0[4+:4];
    return ordering_control;
  endfunction

  function automatic rice_core_trap_control decode_trap_control(rice_riscv_inst inst_bits);
    rice_core_trap_control  trap_control;
    trap_control.ecall  = match_ecall(inst_bits);
    trap_control.ebreak = match_ebreak(inst_bits);
    trap_control.mret   = match_mret(inst_bits);
    return trap_control;
  endfunction

  function automatic rice_core_csr_access decode_csr_access(rice_riscv_inst inst_bits);
    case (1'b1)
      match_csrrw(inst_bits):   return RICE_CORE_CSR_ACCESS_RW;
      match_csrrwi(inst_bits):  return RICE_CORE_CSR_ACCESS_RWI;
      match_csrrs(inst_bits):   return RICE_CORE_CSR_ACCESS_RS;
      match_csrrsi(inst_bits):  return RICE_CORE_CSR_ACCESS_RSI;
      match_csrrc(inst_bits):   return RICE_CORE_CSR_ACCESS_RC;
      match_csrrci(inst_bits):  return RICE_CORE_CSR_ACCESS_RCI;
      default:                  return RICE_CORE_CSR_ACCESS_NONE;
    endcase
  endfunction

//--------------------------------------------------------------
//  Forwarding
//--------------------------------------------------------------
  rice_core_forwarding #(
    .XLEN (XLEN ),
    .ID_RESULT  (rice_core_id_result  ),
    .EX_RESULT  (rice_core_ex_result  )
  ) u_forwarding (
    .i_clk        (i_clk                  ),
    .i_rst_n      (i_rst_n                ),
    .i_enable     (i_enable               ),
    .i_stall      (pipeline_if.stall      ),
    .i_id_result  (id_result              ),
    .i_ex_result  (pipeline_if.ex_result  ),
    .o_id_result  (pipeline_if.id_result  )
  );

//--------------------------------------------------------------
//  Debug
//--------------------------------------------------------------
  if (RICE_CORE_DEBUG) begin : g_debug
    rice_riscv_inst_r_type  inst_r_type;
    rice_riscv_inst_i_type  inst_i_type;
    rice_riscv_inst_s_type  inst_s_type;
    rice_riscv_inst_b_type  inst_b_type;
    rice_riscv_inst_u_type  inst_u_type;
    rice_riscv_inst_j_type  inst_j_type;

    always_comb begin
      inst_r_type = rice_riscv_inst_r_type'(if_result.inst);
      inst_i_type = rice_riscv_inst_i_type'(if_result.inst);
      inst_s_type = rice_riscv_inst_s_type'(if_result.inst);
      inst_b_type = rice_riscv_inst_b_type'(if_result.inst);
      inst_u_type = rice_riscv_inst_u_type'(if_result.inst);
      inst_j_type = rice_riscv_inst_j_type'(if_result.inst);
    end
  end
endmodule
