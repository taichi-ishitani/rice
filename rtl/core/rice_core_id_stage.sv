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
        id_result.pc            <= if_result.pc;
        id_result.rs1           <= decode_rs1(if_result.inst);
        id_result.rs2           <= decode_rs2(if_result.inst);
        id_result.rd            <= decode_rd(if_result.inst);
        id_result.rs1_value     <= get_rs1_value(if_result.inst, pipeline_if.register_file);
        id_result.rs2_value     <= get_rs2_value(if_result.inst, pipeline_if.register_file);
        id_result.imm_value     <= get_imm_value(if_result.inst);
        id_result.alu_operation <= RICE_CORE_ALU_NONE;
        id_result.alu_operand_1 <= rice_core_alu_operand'(0);
        id_result.alu_operand_2 <= rice_core_alu_operand'(0);
        id_result.memory_access <= decode_memory_access(if_result.inst);
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
endmodule
