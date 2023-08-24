module tb_rice_core_env_pipeline_monitor_if_wrapper
  import  rice_riscv_pkg::*,
          rice_core_pkg::*;
(
  input var                     i_clk,
  input var                     i_rst_n,
  rice_bus_if.monitor           inst_bus_if,
  rice_core_pipeline_if.monitor pipeline_if
);
  bit isnt_request_issued;
  bit if_valid;
  bit id_valid;
  bit ex_valid;
  bit wb_valid;
  bit flush;

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      isnt_request_issued <= '0;
    end
    else if (inst_bus_if.request_ack()) begin
      isnt_request_issued <= '0;
    end
    else if (!isnt_request_issued) begin
      isnt_request_issued <= inst_bus_if.request_valid;
    end
  end

  always_comb begin
    if_valid  = pipeline_if.if_result.valid && (!pipeline_if.stall);
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      id_valid  <= '0;
      ex_valid  <= '0;
      wb_valid  <= '0;
      flush     <= '0;
    end
    else begin
      id_valid  <= pipeline_if.if_result.valid && (!pipeline_if.stall) && (!pipeline_if.flush);
      ex_valid  <= pipeline_if.id_result.valid && (!pipeline_if.stall);
      wb_valid  <= ex_valid;
      flush     <= pipeline_if.flush;
    end
  end

  tb_rice_core_env_pipeline_monitor_if  monitor_if(i_clk, i_rst_n);

  always_comb begin
    monitor_if.inst_request_valid   = inst_bus_if.request_valid;
    monitor_if.inst_request_ack     = inst_bus_if.request_ack();
    monitor_if.inst_request_address = inst_bus_if.address;
    monitor_if.isnt_request_issued  = isnt_request_issued;
  end

  always_comb begin
    monitor_if.if_result.valid  = pipeline_if.if_result.valid;
    monitor_if.if_result.pc     = pipeline_if.if_result.pc;
    monitor_if.if_result.inst   = pipeline_if.if_result.inst;
  end

  always_comb begin
    monitor_if.id_result.valid            = pipeline_if.id_result.valid;
    monitor_if.id_result.pc               = pipeline_if.id_result.pc;
    monitor_if.id_result.inst             = pipeline_if.id_result.inst;
    monitor_if.id_result.rs1              = pipeline_if.id_result.rs1;
    monitor_if.id_result.rs2              = pipeline_if.id_result.rs2;
    monitor_if.id_result.rs1_value        = pipeline_if.id_result.rs1_value;
    monitor_if.id_result.rs2_value        = pipeline_if.id_result.rs2_value;
    monitor_if.id_result.imm_value        = pipeline_if.id_result.imm_value;
    monitor_if.id_result.alu_operation    = pipeline_if.id_result.alu_operation;
    monitor_if.id_result.jamp_operation   = pipeline_if.id_result.jamp_operation;
    monitor_if.id_result.memory_access    = pipeline_if.id_result.memory_access;
    monitor_if.id_result.csr_access       = pipeline_if.id_result.csr_access;
    monitor_if.id_result.trap_control     = pipeline_if.id_result.trap_control;
  end

  always_comb begin
    monitor_if.ex_result.valid    = pipeline_if.ex_result.valid;
    monitor_if.ex_result.error    = pipeline_if.ex_result.error;
    monitor_if.ex_result.rd       = pipeline_if.ex_result.rd;
    monitor_if.ex_result.rd_value = pipeline_if.ex_result.rd_value;
  end

  always_comb begin
    monitor_if.if_valid = if_valid;
    monitor_if.id_valid = id_valid;
    monitor_if.ex_valid = ex_valid;
    monitor_if.wb_valid = wb_valid;
    monitor_if.flush    = flush;
  end
endmodule
