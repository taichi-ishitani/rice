module tb;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tb_rice_core_env_pkg::*;
  import  tb_rice_core_test_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  tvip_clock_if clock_if();
  tvip_reset_if reset_if(clock_if.clk);

  rice_bus_if inst_bus_if();
  rice_bus_if data_bus_if();

  tb_rice_bus_slave_bfm u_inst_bus_bfm (
    .i_clk    (clock_if.clk     ),
    .i_rst_n  (reset_if.reset_n ),
    .bus_if   (inst_bus_if      )
  );

  tb_rice_bus_slave_bfm u_data_bus_bfm (
    .i_clk    (clock_if.clk     ),
    .i_rst_n  (reset_if.reset_n ),
    .bus_if   (data_bus_if      )
  );

  rice_core duv (
    .i_clk        (clock_if.clk     ),
    .i_rst_n      (reset_if.reset_n ),
    .inst_bus_if  (inst_bus_if      ),
    .data_bus_if  (data_bus_if      )
  );

  function automatic tb_rice_core_env_context create_tb_context();
    tb_rice_core_env_context  tb_context;

    tb_context              = new("tb_context");
    tb_context.clock_vif    = clock_if;
    tb_context.reset_vif    = reset_if;
    tb_context.inst_bus_vif = u_inst_bus_bfm.bfm_if;
    tb_context.data_bus_vif = u_data_bus_bfm.bfm_if;

    return tb_context;
  endfunction

  initial begin
    tb_rice_env_base_pkg::run_uvm_test(create_tb_context());
  end
endmodule
