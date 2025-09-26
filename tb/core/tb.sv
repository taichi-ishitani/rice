module tb;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tb_rice_core_env_pkg::*;
  import  tb_rice_core_test_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  tvip_clock_if clock_if();
  tvip_reset_if reset_if(clock_if.clk);

  `TB_RICE_DUT_WRAPPER dut_wrapper (
    .i_clk    (clock_if.clk     ),
    .i_rst_n  (reset_if.reset_n )
  );

  function automatic tb_rice_core_env_context create_tb_context();
    tb_rice_core_env_context  tb_context;

    tb_context              = new("tb_context");
    tb_context.clock_vif    = clock_if;
    tb_context.reset_vif    = reset_if;
    tb_context.inst_bus_vif = dut_wrapper.u_inst_bus_bfm.bfm_if;
    tb_context.data_bus_vif = dut_wrapper.u_data_bus_bfm.bfm_if;
    tb_context.pipeline_if  = dut_wrapper.get_pipeline_if_proxy();

    return tb_context;
  endfunction

  initial begin
    tb_rice_env_base_pkg::run_uvm_test(create_tb_context());
  end
endmodule
