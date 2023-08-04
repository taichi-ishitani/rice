interface tb_rice_bus_if (
  input var i_clk,
  input var i_rst_n
);
  localparam  int ADDRESS_WIDTH = 64;
  localparam  int DATA_WIDTH    = 64;
  localparam  int STROBE_WIDTH  = DATA_WIDTH / 8;

  logic                     request_ready;
  logic                     request_valid;
  logic [ADDRESS_WIDTH-1:0] address;
  logic [STROBE_WIDTH-1:0]  strobe;
  logic [DATA_WIDTH-1:0]    write_data;
  logic                     response_ready;
  logic                     response_valid;
  logic [DATA_WIDTH-1:0]    read_data;
  logic                     error;

  clocking master_cb @(posedge i_clk, negedge i_rst_n);
    input   request_ready;
    output  request_valid;
    output  address;
    output  strobe;
    output  write_data;
    output  response_ready;
    input   response_valid;
    input   read_data;
    input   error;
  endclocking

  clocking slave_cb @(posedge i_clk, negedge i_rst_n);
    output  request_ready;
    input   request_valid;
    input   address;
    input   strobe;
    input   write_data;
    input   response_ready;
    output  response_valid;
    output  read_data;
    output  error;
  endclocking

  clocking monitor_cb @(posedge i_clk, negedge i_rst_n);
    input request_ready;
    input request_valid;
    input address;
    input strobe;
    input write_data;
    input response_ready;
    input response_valid;
    input read_data;
    input error;
  endclocking

  event at_master_cb_edge;
  event at_slave_cb_edge;

  always @(master_cb) begin
    ->at_master_cb_edge;
  end

  always @(slave_cb) begin
    ->at_slave_cb_edge;
  end
endinterface
