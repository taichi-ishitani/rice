module tb;
  timeunit  1ns;

  import  uvm_pkg::*;
  import  tue_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  tvip_clock_if clock_if();
  tvip_reset_if reset_if(clock_if.clk);

  rice_bus_if inst_bus_if();
  rice_bus_if data_bus_if();

  rice_core duv (
    .i_clk        (clock_if.clk     ),
    .i_rst_n      (reset_if.reset_n ),
    .inst_bus_if  (inst_bus_if      ),
    .data_bus_if  (data_bus_if      )
  );
endmodule
