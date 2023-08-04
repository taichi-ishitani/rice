module rice_bus_demux #(
  parameter int ADDRESS_WIDTH     = 32,
  parameter int DATA_WIDTH        = 32,
  parameter bit NON_POSTED_WRITE  = 0,
  parameter int MASTERS           = 2,
  parameter int SELECT_WIDTH      = $clog2(MASTERS)
)(
  input var                     i_clk,
  input var                     i_rst_n,
  input var [SELECT_WIDTH-1:0]  i_select,
  rice_bus_if.slave             slave_if,
  rice_bus_if.master            master_if[MASTERS]
);
  logic                               request_done;
  logic                               np_requeset_ack;
  logic [MASTERS-1:0]                 request_ready;
  logic [SELECT_WIDTH-1:0]            respnose_select;
  logic [MASTERS-1:0]                 response_valid;
  logic [MASTERS-1:0][DATA_WIDTH-1:0] read_data;
  logic [MASTERS-1:0]                 error;

//--------------------------------------------------------------
//  Request
//--------------------------------------------------------------
  always_comb begin
    if (NON_POSTED_WRITE) begin
      np_requeset_ack = slave_if.request_ack();
    end
    else begin
      np_requeset_ack = slave_if.read_request_ack();
    end
  end

  always_ff @(posedge  i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      request_done  <= '0;
    end
    else if (slave_if.response_ack()) begin
      request_done  <= '0;
    end
    else if (np_requeset_ack) begin
      request_done  <= '1;
    end
  end

  always_comb begin
    slave_if.request_ready  = (!request_done) && (request_ready != '0);
  end

  for (genvar i = 0;i < MASTERS;++i) begin : g_request
    always_comb begin
      if (i_select == SELECT_WIDTH'(i)) begin
        request_ready[i]            = master_if[i].request_ready;
        master_if[i].request_valid  = (!request_done) && slave_if.request_valid;
      end
      else begin
        request_ready[i]            = '0;
        master_if[i].request_valid  = '0;
      end

      master_if[i].address    = slave_if.address;
      master_if[i].strobe     = slave_if.strobe;
      master_if[i].write_data = slave_if.write_data;
    end
  end

//--------------------------------------------------------------
//  Response
//--------------------------------------------------------------
  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      respnose_select <= SELECT_WIDTH'(0);
    end
    else if (np_requeset_ack) begin
      respnose_select <= i_select;
    end
  end

  for (genvar i = 0;i < MASTERS;++i) begin : g_response
    always_comb begin
      if (respnose_select == SELECT_WIDTH'(i)) begin
        master_if[i].response_ready = slave_if.response_ready;
        response_valid[i]           = master_if[i].response_valid;
      end
      else begin
        master_if[i].response_ready = '0;
        response_valid[i]           = '0;
      end

      read_data[i]  = master_if[i].read_data;
      error[i]      = master_if[i].error;
    end
  end

  always_comb begin
    slave_if.response_valid = response_valid != '0;
    slave_if.read_data      = read_data[respnose_select];
    slave_if.error          = error[respnose_select];
  end
endmodule
