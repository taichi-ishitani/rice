module rice_core_ex_stage
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input var                       i_clk,
  input var                       i_rst_n,
  input var                       i_enable,
  rice_core_pipeline_if.ex_stage  pipeline_if,
  rice_bus_if.master              data_bus_if,
  rice_bus_if.master              csr_if
);
  `rice_core_define_types(XLEN)

  rice_core_id_result id_result;
  rice_core_value     rs1_value;
  rice_core_value     rs2_value;
  rice_core_ex_result wb_result;
  logic [XLEN-1:0]    alu_data;
  logic               flush;
  rice_core_pc        flush_pc;
  logic               memory_access_valid;
  logic [1:0]         memory_access_done;
  logic [XLEN-1:0]    memory_access_data;
  logic               csr_access_valid;
  logic               csr_access_done;
  logic [XLEN-1:0]    csr_access_data;
  logic               csr_access_error;
  logic [1:0]         stall;
  logic               ex_result_valid;
  rice_core_ex_result ex_result;

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
    rice_core_rs        rs,
    rice_core_value     rs_value,
    rice_core_ex_result wb_result,
    rice_core_ex_result ex_result
  );
    logic [1:0] forwarding;
    forwarding[1] = wb_result.valid && (rs == wb_result.rd) && (rs != rice_core_rs'(0));
    forwarding[0] = ex_result.valid && (rs == ex_result.rd) && (rs != rice_core_rs'(0));
    if (forwarding[1]) begin
      return wb_result.rd_value;
    end
    else if (forwarding[0]) begin
      return ex_result.rd_value;
    end
    else begin
      return rs_value;
    end
  endfunction

//--------------------------------------------------------------
//  ALU
//--------------------------------------------------------------
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
//  PC control
//--------------------------------------------------------------
  always_comb begin
    pipeline_if.flush     = flush;
    pipeline_if.flush_pc  = flush_pc;
  end

  always_comb begin
    flush     = get_flush(id_result, alu_data);
    flush_pc  = get_flush_pc(id_result, rs1_value);
  end

  function automatic logic get_flush(
    rice_core_id_result id_result,
    rice_core_value     alu_data
  );
    rice_core_jamp_operation    jamp;
    rice_core_branch_operation  branch;
    logic [3:0]                 flush;

    jamp      = id_result.jamp_operation;
    branch    = id_result.branch_operation;
    flush[0]  = jamp.jal;
    flush[1]  = jamp.jalr;
    flush[2]  = branch.eq_ge && (alu_data == '0);
    flush[3]  = branch.ne_lt && (alu_data != '0);

    return id_result.valid && (flush != '0);
  endfunction

  function automatic rice_core_pc get_flush_pc(
    rice_core_id_result id_result,
    rice_core_value     rs1_value
  );
    rice_core_jamp_operation  jamp;
    rice_core_pc              pc;

    jamp  = id_result.jamp_operation;
    case (1'b1)
      jamp.jalr:  pc  = rs1_value + id_result.imm_value;
      default:    pc  = id_result.pc + id_result.imm_value;
    endcase

    return pc & {{XLEN-1{1'b1}}, 1'b0};
  endfunction

//--------------------------------------------------------------
//  Load/Store unit
//--------------------------------------------------------------
  always_comb begin
    memory_access_valid =
      id_result.valid &&
      (id_result.memory_access.access_type != RICE_CORE_MEMORY_ACCESS_NONE);
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
    csr_access_valid  =
      id_result.valid &&
      (id_result.csr_access != RICE_CORE_CSR_ACCESS_NONE);
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
    pipeline_if.stall = stall[0] || stall[1];
  end

  always_comb begin
    stall[0]  = memory_access_valid && (memory_access_done == '0);
    stall[1]  = csr_access_valid && (!csr_access_done);
  end

//--------------------------------------------------------------
//  Result
//--------------------------------------------------------------
  always_comb begin
    pipeline_if.ex_result = ex_result;
  end

  always_comb begin
    ex_result_valid  =
      (id_result.valid && (!memory_access_valid) && (!csr_access_valid)) ||
      (memory_access_done != '0) || csr_access_done;
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
        ex_result.rd  <= pipeline_if.id_result.rd;
        case (1'b1)
          memory_access_done[1]:
            ex_result.rd_value  <= memory_access_data;
          csr_access_done:
            ex_result.rd_value  <= csr_access_data;
          default:
            ex_result.rd_value  <= alu_data;
        endcase
      end
    end
  end
endmodule
