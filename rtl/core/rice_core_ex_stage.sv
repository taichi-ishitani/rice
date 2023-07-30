module rice_core_ex_stage
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input var                       i_clk,
  input var                       i_rst_n,
  input var                       i_enable,
  rice_core_pipeline_if.ex_stage  pipeline_if,
  rice_bus_if.master              data_bus_if
);
  `rice_core_define_types(XLEN)

  rice_core_value     rs1_value;
  rice_core_value     rs2_value;
  rice_core_ex_result wb_result;
  logic               alu_valid;
  logic [XLEN-1:0]    alu_data;
  logic               memory_access_valid;
  logic [1:0]         memory_access_done;
  logic [XLEN-1:0]    memory_access_data;
  logic               stall;
  logic               ex_result_valid;
  rice_core_ex_result ex_result;

  always_comb begin
    pipeline_if.flush     = '0;
    pipeline_if.flush_pc  = '0;
  end

//--------------------------------------------------------------
//  Forwarding
//--------------------------------------------------------------
  always_comb begin
    rs1_value =
      get_rs_value(
        pipeline_if.id_result.rs1, pipeline_if.id_result.rs1_value,
        wb_result, ex_result
      );
    rs2_value =
      get_rs_value(
        pipeline_if.id_result.rs2, pipeline_if.id_result.rs2_value,
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
  always_comb begin
    alu_valid =
      pipeline_if.id_result.valid && i_enable &&
      (pipeline_if.id_result.alu_operation.command != RICE_CORE_ALU_NONE);
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
//  Load/Store unit
//--------------------------------------------------------------
  always_comb begin
    memory_access_valid =
      pipeline_if.id_result.valid && i_enable &&
      (pipeline_if.id_result.memory_access.access_type != RICE_CORE_MEMORY_ACCESS_NONE);
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
//  Stall control
//--------------------------------------------------------------
  always_comb begin
    pipeline_if.stall=  stall;
  end

  always_comb begin
    stall = memory_access_valid && (memory_access_done == '0);
  end

//--------------------------------------------------------------
//  Result
//--------------------------------------------------------------
  always_comb begin
    pipeline_if.ex_result = ex_result;
  end

  always_comb begin
    ex_result_valid  =
      alu_valid || (memory_access_done != '0);
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
        if (memory_access_done[1]) begin
          ex_result.rd_value  <= memory_access_data;
        end
        else begin
          ex_result.rd_value  <= alu_data;
        end
      end
    end
  end
endmodule
