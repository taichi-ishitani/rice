module rice_bus_connector (
  interface.slave   slave_if,
  interface.master  master_if
);
  always_comb begin
    slave_if.request_ready  = master_if.request_ready;
    master_if.request_valid = slave_if.request_valid;
    master_if.address       = slave_if.address;
    master_if.strobe        = slave_if.strobe;
    master_if.write_data    = slave_if.write_data;
  end

  always_comb begin
    master_if.response_ready  = slave_if.response_ready;
    slave_if.response_valid   = master_if.response_valid;
    slave_if.read_data        = master_if.read_data;
    slave_if.error            = master_if.error;
  end
endmodule
