module rggen_rice_bus_if_adapter
  import  rggen_rtl_pkg::*;
#(
  parameter int                     ADDRESS_WIDTH       = 14,
  parameter int                     LOCAL_ADDRESS_WIDTH = ADDRESS_WIDTH,
  parameter int                     BUS_WIDTH           = 32,
  parameter int                     REGISTERS           = 1,
  parameter bit                     PRE_DECODE          = 0,
  parameter bit [ADDRESS_WIDTH-1:0] BASE_ADDRESS        = '0,
  parameter int                     BYTE_SIZE           = 1,
  parameter bit                     ERROR_STATUS        = 0,
  parameter bit [BUS_WIDTH-1:0]     DEFAULT_READ_DATA   = '0,
  parameter bit                     INSERT_SLICER       = 0
)(
  input var               i_clk,
  input var               i_rst_n,
  rice_bus_if.slave       csr_if,
  rggen_register_if.host  register_if[REGISTERS]
);
  localparam  int BYTE_WIDTH  = BUS_WIDTH / 8;
  localparam  int ADDRESS_LSB = $clog2(BYTE_WIDTH);

  logic                                               response_valid;
  logic [BUS_WIDTH-1:0]                               read_data;
  logic                                               error;
  rggen_bus_if #(ADDRESS_WIDTH, BUS_WIDTH, BUS_WIDTH) bus_if();

  //  Request
  always_comb begin
    csr_if.request_ready  = bus_if.ready && (!response_valid);
    bus_if.valid          = csr_if.request_valid && (!response_valid);
    bus_if.access         = (csr_if.strobe != '0) ? RGGEN_WRITE : RGGEN_READ;
    bus_if.address        = {csr_if.address, ADDRESS_LSB'(0)};
    bus_if.write_data     = csr_if.write_data;
    bus_if.strobe         = csr_if.strobe;
  end

  //  Response
  always_comb begin
    csr_if.response_valid = response_valid;
    csr_if.read_data      = read_data;
    csr_if.error          = error;
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      response_valid  <= '0;
    end
    else if (csr_if.response_ack()) begin
      response_valid  <= '0;
    end
    else if (bus_if.valid && bus_if.ready) begin
      response_valid  <= '1;
    end
  end

  always_ff @(posedge i_clk) begin
    if (bus_if.valid && bus_if.ready) begin
      read_data <= bus_if.read_data;
    end
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      error <= '0;
    end
    else if (bus_if.valid && bus_if.ready) begin
      error <= bus_if.status[1];
    end
  end

  //  Adapter
  rggen_adapter_common #(
    .ADDRESS_WIDTH        (ADDRESS_WIDTH        ),
    .LOCAL_ADDRESS_WIDTH  (LOCAL_ADDRESS_WIDTH  ),
    .BUS_WIDTH            (BUS_WIDTH            ),
    .STROBE_WIDTH         (BUS_WIDTH            ),
    .REGISTERS            (REGISTERS            ),
    .PRE_DECODE           (PRE_DECODE           ),
    .BASE_ADDRESS         (BASE_ADDRESS         ),
    .BYTE_SIZE            (BYTE_SIZE            ),
    .ERROR_STATUS         (ERROR_STATUS         ),
    .DEFAULT_READ_DATA    (DEFAULT_READ_DATA    ),
    .INSERT_SLICER        (INSERT_SLICER        )
  ) u_adapter_common (
    .i_clk        (i_clk        ),
    .i_rst_n      (i_rst_n      ),
    .bus_if       (bus_if       ),
    .register_if  (register_if  )
  );
endmodule
