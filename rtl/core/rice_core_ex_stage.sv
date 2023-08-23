module rice_core_ex_stage
  import  rice_riscv_pkg::*,
          rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input var                       i_clk,
  input var                       i_rst_n,
  input var                       i_enable,
  rice_core_pipeline_if.ex_stage  pipeline_if,
  rice_core_env_if.ex_stage       env_if,
  rice_bus_if.master              data_bus_if,
  rice_bus_if.master              csr_if
);
  `rice_core_define_types(XLEN)

  typedef struct packed {
    logic alu;
    logic mul;
    logic div;
    logic jamp;
    logic memory;
    logic ordering;
    logic trap;
    logic csr;
  } rice_core_ex_type;

  typedef struct packed {
    logic illegal_instruction;
    logic misaligned_pc;
    logic csr_access;
  } rice_core_ex_error;

  rice_core_id_result       id_result;
  rice_core_value           rs1_value;
  rice_core_value           rs2_value;
  rice_core_ex_result       wb_result;
  logic                     flush;
  rice_core_pc              flush_pc;
  rice_core_jamp_operation  jamp_condition;
  rice_core_pc              jamp_pc;
  logic [XLEN-1:0]          alu_data;
  logic                     mul_valid;
  logic                     mul_done;
  logic [XLEN-1:0]          mul_data;
  logic                     div_valid;
  logic                     div_done;
  logic [XLEN-1:0]          div_data;
  logic                     memory_access_valid;
  logic [1:0]               memory_access_done;
  logic [XLEN-1:0]          memory_access_data;
  logic                     csr_access_valid;
  logic                     csr_access_done;
  logic [XLEN-1:0]          csr_access_data;
  logic                     csr_access_error;
  logic                     stall;
  rice_core_exception       exception;
  rice_core_ex_type         ex_valid;
  rice_core_ex_type         ex_done;
  logic                     ex_result_valid;
  rice_core_ex_result       ex_result;
  rice_core_ex_error        ex_error;

  function automatic logic is_valid_alu_operation(rice_core_id_result id_result);
    return id_result.alu_operation.command != RICE_CORE_ALU_NONE;
  endfunction

  function automatic logic is_valid_mul_operation(rice_core_id_result id_result);
    return id_result.mul_operation != '0;
  endfunction

  function automatic logic is_valid_div_operation(rice_core_id_result id_result);
    return id_result.div_operation != '0;
  endfunction

  function automatic logic is_valid_jamp_operation(rice_core_id_result id_result);
    return id_result.jamp_operation != '0;
  endfunction

  function automatic logic is_valid_memory_access(rice_core_id_result id_result);
    return id_result.memory_access.access_type != RICE_CORE_MEMORY_ACCESS_NONE;
  endfunction

  function automatic logic is_valid_odering_control(rice_core_id_result id_result);
    return id_result.ordering_control.fence || id_result.ordering_control.fence_i;
  endfunction

  function automatic logic is_valid_trap_control(rice_core_id_result id_result);
    return id_result.trap_control != '0;;
  endfunction

  function automatic logic is_valid_csr_access(rice_core_id_result id_result);
    return id_result.csr_access != RICE_CORE_CSR_ACCESS_NONE;
  endfunction

  always_comb begin
    id_result = pipeline_if.id_result;
  end

//--------------------------------------------------------------
//  Forwarding
//--------------------------------------------------------------
  always_comb begin
    rs1_value =
      get_rs_value(
        id_result.rs1, id_result.rs1_value,
        wb_result, ex_result
      );
    rs2_value =
      get_rs_value(
        id_result.rs2, id_result.rs2_value,
        wb_result, ex_result
      );
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      wb_result <= rice_core_ex_result'(0);
    end
    else if (!i_enable) begin
      wb_result <= rice_core_ex_result'(0);
    end
    else if (!stall) begin
      wb_result <= ex_result;
    end
  end

  function automatic rice_core_value get_rs_value(
    rice_riscv_rs       rs,
    rice_core_value     rs_value,
    rice_core_ex_result wb_result,
    rice_core_ex_result ex_result
  );
    logic [1:0] forwarding;
    forwarding[1] = wb_result.valid && (rs == wb_result.rd) && (rs != rice_riscv_rs'(0));
    forwarding[0] = ex_result.valid && (rs == ex_result.rd) && (rs != rice_riscv_rs'(0));
    case (1'b1)
      forwarding[0]:  return ex_result.rd_value;
      forwarding[1]:  return wb_result.rd_value;
      default:        return rs_value;
    endcase
  endfunction

//--------------------------------------------------------------
//  PC control
//--------------------------------------------------------------
  always_comb begin
    pipeline_if.flush     = flush;
    pipeline_if.flush_pc  = flush_pc;
  end

  always_comb begin
    flush     = get_flush(id_result, jamp_condition, exception);
    flush_pc  = get_flush_pc(id_result, exception, env_if.trap_pc, env_if.return_pc, jamp_pc);
  end

  always_comb begin
    jamp_condition  = check_jamp_condition(id_result, alu_data);
    jamp_pc         = calc_jamp_pc(id_result, rs1_value);
  end

  always_comb begin
    ex_valid.jamp     = is_valid_jamp_operation(id_result);
    ex_valid.ordering = is_valid_odering_control(id_result);
    ex_valid.trap     = is_valid_trap_control(id_result);
    ex_done.jamp      = '1;
    ex_done.ordering  = '1;
    ex_done.trap      = '1;
  end

  always_comb begin
    ex_error.misaligned_pc  = check_misaligned_pc(jamp_condition, jamp_pc);
  end

  function automatic logic get_flush(
    rice_core_id_result       id_result,
    rice_core_jamp_operation  jamp_condition,
    rice_core_exception       exception
  );
    rice_core_ordering_control  ordering;
    rice_core_trap_control      trap;
    logic [3:0]                 flush;

    ordering  = id_result.ordering_control;
    trap      = id_result.trap_control;
    flush[0]  = jamp_condition != '0;
    flush[1]  = id_result.valid && ordering.fence_i;
    flush[2]  = id_result.valid && trap.mret;
    flush[3]  = exception != '0;

    return flush != '0;
  endfunction

  function automatic rice_core_pc get_flush_pc(
    rice_core_id_result id_result,
    rice_core_exception exception,
    rice_core_pc        trap_pc,
    rice_core_pc        return_pc,
    rice_core_pc        jamp_pc
  );
    rice_core_ordering_control  ordering;
    rice_core_trap_control      trap;

    ordering  = id_result.ordering_control;
    trap      = id_result.trap_control;
    case (1'b1)
      ordering.fence_i: return id_result.pc + XLEN'(4);
      trap.mret:        return return_pc;
      exception != '0:  return trap_pc;
      default:          return jamp_pc;
    endcase
  endfunction

  function automatic rice_core_jamp_operation check_jamp_condition(
    rice_core_id_result id_result,
    rice_core_value     alu_data
  );
    logic                     valid;
    rice_core_jamp_operation  jamp_operation;
    rice_core_jamp_operation  jamp_condition;

    valid                   = id_result.valid;
    jamp_operation          = id_result.jamp_operation;
    jamp_condition.jal      = valid && jamp_operation.jal;
    jamp_condition.jalr     = valid && jamp_operation.jalr;
    jamp_condition.beq_bge  = valid && jamp_operation.beq_bge && (alu_data == '0);
    jamp_condition.bne_blt  = valid && jamp_operation.bne_blt && (alu_data != '0);

    return jamp_condition;
  endfunction

  function automatic rice_core_pc calc_jamp_pc(
    rice_core_id_result id_result,
    rice_core_value     rs1_value
  );
    rice_core_pc  pc;

    if (id_result.jamp_operation.jalr) begin
      pc  = rs1_value + id_result.imm_value;
    end
    else begin
      pc  = id_result.pc + id_result.imm_value;
    end

    pc[0] = '0;
    return pc;
  endfunction

  function automatic logic check_misaligned_pc(
    rice_core_jamp_operation  jamp_condition,
    rice_core_pc              jamp_pc
  );
    return (jamp_condition != '0) && (jamp_pc[1:0] != '0);
  endfunction

//--------------------------------------------------------------
//  ALU
//--------------------------------------------------------------
  always_comb begin
    ex_valid.alu  = is_valid_alu_operation(id_result);
    ex_done.alu   = '1;
  end

  rice_core_alu #(
    .XLEN (XLEN )
  ) u_alu (
    .i_pc             (pipeline_if.id_result.pc             ),
    .i_rs1_value      (rs1_value                            ),
    .i_rs2_value      (rs2_value                            ),
    .i_imm_value      (pipeline_if.id_result.imm_value      ),
    .i_alu_operation  (pipeline_if.id_result.alu_operation  ),
    .o_result         (alu_data                             )
  );

//--------------------------------------------------------------
//  Multiplier
//--------------------------------------------------------------
  always_comb begin
    ex_valid.mul  = is_valid_mul_operation(id_result);
    ex_done.mul   = mul_done;
  end

  always_comb begin
    mul_valid     = id_result.valid && ex_valid.mul;
  end

  rice_core_mul #(
    .XLEN (XLEN )
  ) u_mul (
    .i_clk            (i_clk                    ),
    .i_rst_n          (i_rst_n                  ),
    .i_valid          (mul_valid                ),
    .i_rs1_value      (rs1_value                ),
    .i_rs2_value      (rs2_value                ),
    .i_mul_operation  (id_result.mul_operation  ),
    .o_result_valid   (mul_done                 ),
    .o_result         (mul_data                 )
  );

//--------------------------------------------------------------
//  Divisor
//--------------------------------------------------------------
  always_comb begin
    ex_valid.div  = is_valid_div_operation(id_result);
    ex_done.div   = div_done;
  end

  always_comb begin
    div_valid     = id_result.valid && ex_valid.div;
  end

  rice_core_div #(
    .XLEN (XLEN )
  ) u_div (
    .i_clk            (i_clk                    ),
    .i_rst_n          (i_rst_n                  ),
    .i_valid          (div_valid                ),
    .i_rs1_value      (rs1_value                ),
    .i_rs2_value      (rs2_value                ),
    .i_div_operation  (id_result.div_operation  ),
    .o_result_valid   (div_done                 ),
    .o_result         (div_data                 )
  );

//--------------------------------------------------------------
//  Load/Store unit
//--------------------------------------------------------------
  always_comb begin
    ex_valid.memory = is_valid_memory_access(id_result);
    ex_done.memory  = memory_access_done != '0;
  end

  always_comb begin
    memory_access_valid = id_result.valid && ex_valid.memory;
  end

  rice_core_lsu #(
    .XLEN (XLEN )
  ) u_lsu (
    .i_clk            (i_clk                                ),
    .i_rst_n          (i_rst_n                              ),
    .i_valid          (memory_access_valid                  ),
    .i_rs1_value      (rs1_value                            ),
    .i_rs2_value      (rs2_value                            ),
    .i_imm_value      (pipeline_if.id_result.imm_value      ),
    .i_memory_access  (pipeline_if.id_result.memory_access  ),
    .o_access_done    (memory_access_done                   ),
    .o_read_data      (memory_access_data                   ),
    .data_bus_if      (data_bus_if                          )
  );

//--------------------------------------------------------------
//  CSR access
//--------------------------------------------------------------
  always_comb begin
    ex_valid.csr  = is_valid_csr_access(id_result);
    ex_done.csr   = csr_access_done;
  end

  always_comb begin
    ex_error.csr_access = csr_access_done && csr_access_error;
  end

  always_comb begin
    csr_access_valid  = id_result.valid && ex_valid.csr;
  end

  rice_core_csr_rw_unit #(
    .XLEN (XLEN )
  ) u_csr_rw_unit (
    .i_clk          (i_clk                ),
    .i_rst_n        (i_rst_n              ),
    .i_valid        (csr_access_valid     ),
    .i_rs1          (id_result.rs1        ),
    .i_rs1_value    (rs1_value            ),
    .i_imm_value    (id_result.imm_value  ),
    .i_csr_access   (id_result.csr_access ),
    .o_access_done  (csr_access_done      ),
    .o_read_data    (csr_access_data      ),
    .o_error        (csr_access_error     ),
    .csr_if         (csr_if               )
  );

//--------------------------------------------------------------
//  Stall control
//--------------------------------------------------------------
  always_comb begin
    pipeline_if.stall = stall;
  end

  always_comb begin
    stall = id_result.valid && (ex_valid != '0) && ((ex_valid & ex_done) == '0);
  end

//--------------------------------------------------------------
//  Env control
//--------------------------------------------------------------
  always_comb begin
    env_if.inst_retired = ex_result_valid && (!stall) && (ex_error == '0);
    env_if.exception    = exception;
    env_if.mret         = id_result.valid && id_result.trap_control.mret;
    env_if.pc           = id_result.pc;
    env_if.inst         = id_result.inst;
  end

  always_comb begin
    ex_error.illegal_instruction  = id_result.valid && (ex_valid == '0);
  end

  always_comb begin
    exception = get_exception(id_result, ex_error, env_if.privilege_level);
  end

  function automatic rice_core_exception get_exception(
    rice_core_id_result       id_result,
    rice_core_ex_error        ex_error,
    rice_core_privilege_level privilege_level
  );
    rice_core_exception exception;
    logic               ebreak;
    logic               ecall;

    ebreak                                    = id_result.valid && id_result.trap_control.ebreak;
    ecall                                     = id_result.valid && id_result.trap_control.ecall;
    exception                                 = '0;
    exception.illegal_instruction             = ex_error.illegal_instruction || ex_error.csr_access;
    exception.breakpoint                      = ebreak;
    exception.ecall_from_u_mode               = ecall && (privilege_level == RICE_CORE_USER_MODE      );
    exception.ecall_from_s_mode               = ecall && (privilege_level == RICE_CORE_SUPERVISOR_MODE);
    exception.ecall_from_m_mode               = ecall && (privilege_level == RICE_CORE_MACHINE_MODE   );
    exception.instruction_address_misaligned  = ex_error.misaligned_pc;

    return exception;
  endfunction

//--------------------------------------------------------------
//  Result
//--------------------------------------------------------------
  always_comb begin
    pipeline_if.ex_result = ex_result;
  end

  always_comb begin
    ex_result_valid  = id_result.valid && (((ex_valid & ex_done) != '0) || (ex_valid == '0));
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      ex_result <= rice_core_ex_result'(0);
    end
    else if (!i_enable) begin
      ex_result <= rice_core_ex_result'(0);
    end
    else if (!stall) begin
      ex_result.valid <= ex_result_valid;
      if (ex_result_valid) begin
        if (ex_error == '0) begin
          ex_result.rd  <= pipeline_if.id_result.rd;
        end
        else begin
          ex_result.rd  <= rice_riscv_rd'(0);
        end

        case (1'b1)
          mul_done:               ex_result.rd_value  <= mul_data;
          div_done:               ex_result.rd_value  <= div_data;
          memory_access_done[1]:  ex_result.rd_value  <= memory_access_data;
          csr_access_done:        ex_result.rd_value  <= csr_access_data;
          default:                ex_result.rd_value  <= alu_data;
        endcase
      end
    end
  end
endmodule
