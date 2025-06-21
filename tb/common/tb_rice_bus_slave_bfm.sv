module tb_rice_bus_slave_bfm (
  input var       i_clk,
  input var       i_rst_n,
  interface.slave bus_if
);
  tb_rice_bus_if  bfm_if(i_clk, i_rst_n);

  always @* begin
    bus_if.request_ready  = bfm_if.request_ready;
    bfm_if.request_valid  = bus_if.request_valid;
    bfm_if.write          = bus_if.write;
    bfm_if.address        = bus_if.address;
    bfm_if.strobe         = bus_if.strobe;
    bfm_if.write_data     = bus_if.write_data;
  end

  always @* begin
    bfm_if.response_ready = bus_if.response_ready;
    bus_if.response_valid = bfm_if.response_valid;
    bus_if.read_data      = bfm_if.read_data;
    bus_if.error          = bfm_if.error;
  end
endmodule
