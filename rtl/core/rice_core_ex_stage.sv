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
    logic branch;
    logic memory;
    logic ordering;
    logic trap;
    logic csr;
  } rice_core_ex_type;

  rice_core_id_result     id_result;
  logic                   flush;
  rice_core_pc            flush_pc;
  logic [XLEN-1:0]        alu_data;
  rice_core_branch_result branch_result;
  logic                   mul_valid;
  logic                   mul_done;
  logic [XLEN-1:0]        mul_data;
  logic                   div_valid;
  logic                   div_done;
  logic [XLEN-1:0]        div_data;
  logic                   memory_access_valid;
  logic [1:0]             memory_access_done;
  logic [XLEN-1:0]        memory_access_data;
  logic                   csr_access_valid;
  logic                   csr_access_done;
  logic [XLEN-1:0]        csr_access_data;
  logic                   csr_access_error;
  logic                   stall;
  rice_core_exception     exception;
  rice_core_ex_type       ex_valid;
  rice_core_ex_type       ex_done;
  logic                   ex_result_valid;
  rice_core_ex_result     ex_result;
  rice_core_ex_error      ex_error;

  function automatic logic is_valid_alu_operation(rice_core_id_result id_result);
    return id_result.alu_operation.command != RICE_CORE_ALU_NONE;
  endfunction

  function automatic logic is_valid_mul_operation(rice_core_id_result id_result);
    return id_result.mul_operation != '0;
  endfunction

  function automatic logic is_valid_div_operation(rice_core_id_result id_result);
    return id_result.div_operation != '0;
  endfunction

  function automatic logic is_valid_branch_operation(rice_core_id_result id_result);
    return id_result.branch_operation != '0;
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
//  PC control
//--------------------------------------------------------------
  always_comb begin
    pipeline_if.flush     = flush;
    pipeline_if.flush_pc  = flush_pc;
  end

  always_comb begin
    flush     = get_flush(id_result, branch_result, exception);
    flush_pc  = get_flush_pc(id_result, branch_result, exception, env_if.trap_pc, env_if.return_pc);
  end

  always_comb begin
    ex_valid.ordering = is_valid_odering_control(id_result);
    ex_valid.trap     = is_valid_trap_control(id_result);
    ex_done.ordering  = '1;
    ex_done.trap      = '1;
  end

  function automatic logic get_flush(
    rice_core_id_result     id_result,
    rice_core_branch_result branch_result,
    rice_core_exception     exception
  );
    logic jamp;
    logic misprediction;
    logic fence_i;
    logic mret;
    jamp          = branch_result.jamp;
    misprediction = branch_result.misprediction != '0;
    fence_i       = id_result.valid && id_result.ordering_control.fence_i;
    mret          = id_result.valid && id_result.trap_control.mret;
    return jamp || misprediction || fence_i || mret || (exception != '0);
  endfunction

  function automatic rice_core_pc get_flush_pc(
    rice_core_id_result     id_result,
    rice_core_branch_result branch_result,
    rice_core_exception     exception,
    rice_core_pc            trap_pc,
    rice_core_pc            return_pc
  );
    rice_core_ordering_control  ordering;
    rice_core_trap_control      trap;
    logic                       rollback;

    ordering  = id_result.ordering_control;
    trap      = id_result.trap_control;
    rollback  = branch_result.misprediction[0];
    case (1'b1)
      ordering.fence_i,
      rollback:         return id_result.pc + XLEN'(4);
      trap.mret:        return return_pc;
      exception != '0:  return trap_pc;
      default:          return branch_result.target_pc;
    endcase
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
    .i_pc             (id_result.pc             ),
    .i_rs1_value      (id_result.rs1_value      ),
    .i_rs2_value      (id_result.rs2_value      ),
    .i_imm_value      (id_result.imm_value      ),
    .i_alu_operation  (id_result.alu_operation  ),
    .o_result         (alu_data                 )
  );

//--------------------------------------------------------------
//  Branch
//--------------------------------------------------------------
  always_comb begin
    pipeline_if.branch_result = branch_result;
  end

  always_comb begin
    branch_result = get_branch_result(id_result, alu_data);
  end

  always_comb begin
    ex_valid.branch         = is_valid_branch_operation(id_result);
    ex_done.branch          = '1;
    ex_error.misaligned_pc  = check_misaligned_pc(branch_result);
  end

  function automatic rice_core_branch_result get_branch_result(
    rice_core_id_result id_result,
    rice_core_value     alu_data
  );
    logic                       valid;
    rice_core_branch_operation  branch_operation;
    rice_core_bp_result         bp_result;
    logic                       match_taken;
    logic                       match_not_taken;
    rice_core_pc                target_pc;
    logic [2:0]                 misprediction;
    rice_core_branch_result     result;

    valid             = id_result.valid;
    branch_operation  = id_result.branch_operation;
    bp_result         = id_result.bp_result;

    //  check branch condition
    match_taken     = (branch_operation.beq_bge && (alu_data == '0)) ||
                      (branch_operation.bne_blt && (alu_data != '0));
    match_not_taken = (branch_operation.beq_bge && (alu_data != '0)) ||
                      (branch_operation.bne_blt && (alu_data == '0));

    //  calc target pc
    if (branch_operation.jalr) begin
      target_pc = id_result.rs1_value + id_result.imm_value;
    end
    else begin
      target_pc = id_result.pc + id_result.imm_value;
    end
    target_pc[0]  = '0;

    //  evaluate prediction result
    misprediction[0]  = bp_result.taken && (!match_taken);
    misprediction[1]  = bp_result.taken && match_taken && (bp_result.target_pc != target_pc);
    misprediction[2]  = match_taken && (!bp_result.taken);

    result.taken            = valid && match_taken;
    result.not_taken        = valid && match_not_taken;
    result.jamp             = valid && (branch_operation.jal || branch_operation.jalr);
    result.pc               = id_result.pc;
    result.target_pc        = target_pc;
    result.misprediction[0] = valid && misprediction[0];
    result.misprediction[1] = valid && misprediction[1];
    result.misprediction[2] = valid && misprediction[2];
    return result;
  endfunction

  function automatic logic check_misaligned_pc(
    rice_core_branch_result branch_result
  );
    return
      (branch_result.taken || branch_result.jamp) &&
      (branch_result.target_pc[1:0] != '0);
  endfunction

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
    .i_rs1_value      (id_result.rs1_value      ),
    .i_rs2_value      (id_result.rs2_value      ),
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
    .i_rs1_value      (id_result.rs1_value      ),
    .i_rs2_value      (id_result.rs2_value      ),
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
    .i_clk            (i_clk                    ),
    .i_rst_n          (i_rst_n                  ),
    .i_valid          (memory_access_valid      ),
    .i_rs1_value      (id_result.rs1_value      ),
    .i_rs2_value      (id_result.rs2_value      ),
    .i_imm_value      (id_result.imm_value      ),
    .i_memory_access  (id_result.memory_access  ),
    .o_access_done    (memory_access_done       ),
    .o_read_data      (memory_access_data       ),
    .data_bus_if      (data_bus_if              )
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
    .i_rs1_value    (id_result.rs1_value  ),
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
        ex_result.error <= ex_error;
        ex_result.rd    <= pipeline_if.id_result.rd;
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
