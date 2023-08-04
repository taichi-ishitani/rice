module rice_bus_slave_dummy #(
  parameter int                   DATA_WIDTH        = 32,
  parameter bit                   NON_POSTED_WRITE  = 0,
  parameter bit [DATA_WIDTH-1:0]  READ_DATA         = '0,
  parameter bit                   ERROR             = 1
)(
  input var         i_clk,
  input var         i_rst_n,
  rice_bus_if.slave slave_if
);
  logic np_requeset_ack;
  logic response_valid;

  always_comb begin
    if (NON_POSTED_WRITE) begin
      np_requeset_ack = slave_if.request_ack();
    end
    else begin
      np_requeset_ack = slave_if.read_request_ack();
    end
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      response_valid  <= '0;
    end
    else if (slave_if.response_ack()) begin
      response_valid  <= '0;
    end
    else if (np_requeset_ack) begin
      response_valid  <= '1;
    end
  end

  always_comb begin
    slave_if.request_ready  = !response_valid;
  end

  always_comb begin
    slave_if.response_valid = response_valid;
    slave_if.read_data      = READ_DATA;
    slave_if.error          = ERROR;
  end
endmodule
