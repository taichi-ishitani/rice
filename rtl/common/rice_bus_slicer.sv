module rice_bus_slicer #(
  parameter int ADDRESS_WIDTH   = 32,
  parameter int DATA_WIDTH      = 32,
  parameter int STROBE_WIDTH    = DATA_WIDTH / 8,
  parameter int STAGES          = 1,
  parameter int REQUEST_STAGES  = STAGES,
  parameter int RESPONSE_STAGES = STAGES,
  parameter bit FULL_BANDWIDTH  = 1
)(
  input var           i_clk,
  input var           i_rst_n,
  rice_bus_if.slave   slave_if,
  rice_bus_if.master  master_if
);
  typedef struct packed {
    logic [ADDRESS_WIDTH-1:0] address;
    logic [STROBE_WIDTH-1:0]  strobe;
    logic [DATA_WIDTH-1:0]    write_data;
  } rice_bus_request;

  typedef struct packed {
    logic [DATA_WIDTH-1:0]  read_data;
    logic                   error;
  } rice_bus_response;

  logic [1:0]             request_ready;
  logic [1:0]             request_valid;
  rice_bus_request  [1:0] request;
  logic [1:0]             response_ready;
  logic [1:0]             response_valid;
  rice_bus_response [1:0] response;

  always_comb begin
    slave_if.request_ready  = request_ready[0];
    request_valid[0]        = slave_if.request_valid;
    request[0].address      = slave_if.address;
    request[0].strobe       = slave_if.strobe;
    request[0].write_data   = slave_if.write_data;
  end

  always_comb begin
    request_ready[1]        = master_if.request_ready;
    master_if.request_valid = request_valid[1];
    master_if.address       = request[1].address;
    master_if.strobe        = request[1].strobe;
    master_if.write_data    = request[1].write_data;
  end

  pzbcm_slicer #(
    .TYPE           (rice_bus_request ),
    .STAGES         (REQUEST_STAGES   ),
    .FULL_BANDWIDTH (FULL_BANDWIDTH   )
  ) u_request_slicer (
    .i_clk    (i_clk            ),
    .i_rst_n  (i_rst_n          ),
    .i_valid  (request_valid[0] ),
    .o_ready  (request_ready[0] ),
    .i_data   (request[0]       ),
    .o_valid  (request_valid[1] ),
    .i_ready  (request_ready[1] ),
    .o_data   (request[1]       )
  );

  always_comb begin
    master_if.response_ready  = response_ready[0];
    response_valid[0]         = master_if.response_valid;
    response[0].read_data     = master_if.read_data;
    response[0].error         = master_if.error;
  end

  always_comb begin
    response_ready[1]       = slave_if.response_ready;
    slave_if.response_valid = response_valid[1];
    slave_if.read_data      = response[1].read_data;
    slave_if.error          = response[1].error;
  end

  pzbcm_slicer #(
    .TYPE           (rice_bus_response  ),
    .STAGES         (RESPONSE_STAGES    ),
    .FULL_BANDWIDTH (FULL_BANDWIDTH     )
  ) u_response_slicer (
    .i_clk    (i_clk              ),
    .i_rst_n  (i_rst_n            ),
    .i_valid  (response_valid[0]  ),
    .o_ready  (response_ready[0]  ),
    .i_data   (response[0]        ),
    .o_valid  (response_valid[1]  ),
    .i_ready  (response_ready[1]  ),
    .o_data   (response[1]        )
  );
endmodule
