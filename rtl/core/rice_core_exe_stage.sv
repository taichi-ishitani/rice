module rice_core_exe_stage
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input var                       i_clk,
  input var                       i_rst_n,
  input var                       i_enable,
  rice_core_pipeline_if.exe_stage pipeline_if,
  rice_bus_if.master              data_bus_if
);
  `rice_core_define_types(XLEN)

  rice_core_value       rs1_value;
  rice_core_value       rs2_value;
  logic                 memory_access_valid;
  logic [1:0]           memory_access_done;
  logic [XLEN-1:0]      memory_access_data;
  logic                 stall;
  logic                 exe_result_valid;
  rice_core_exe_result  exe_result;

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
        exe_result.valid, exe_result.rd, exe_result.rd_value
      );
    rs2_value =
      get_rs_value(
        pipeline_if.id_result.rs2, pipeline_if.id_result.rs2_value,
        exe_result.valid, exe_result.rd, exe_result.rd_value
      );
  end

  function automatic rice_core_value get_rs_value(
    rice_core_rs    rs,
    rice_core_value rs_value,
    logic           rd_valid,
    rice_core_rs    rd,
    rice_core_value rd_value
  );
    if (rd_valid && (rs == rd) && (rs != rice_core_rs'(0))) begin
      return rd_value;
    end
    else begin
      return rs_value;
    end
  endfunction

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
    pipeline_if.exe_result  = exe_result;
  end

  always_comb begin
    exe_result_valid  = memory_access_done[1];
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      exe_result  <= rice_core_exe_result'(0);
    end
    else if (!i_enable) begin
      exe_result  <= rice_core_exe_result'(0);
    end
    else if (!stall) begin
      exe_result.valid  <= exe_result_valid;
      if (exe_result_valid) begin
        exe_result.rd <= pipeline_if.id_result.rd;
        if (memory_access_done) begin
          exe_result.rd_value <= memory_access_data;
        end
      end
    end
  end
endmodule
