module rggen_rice_register_variable_access
  import  rggen_rtl_pkg::*;
#(
  parameter int                     ADDRESS_WIDTH   = 8,
  parameter bit [ADDRESS_WIDTH-1:0] OFFSET_ADDRESS  = '0,
  parameter int                     BUS_WIDTH       = 32,
  parameter int                     DATA_WIDTH      = BUS_WIDTH,
  parameter int                     VALUE_WIDTH     = BUS_WIDTH
)(
  input var                   i_clk,
  input var                   i_rst_n,
  input var                   i_write_enable,
  input var                   i_read_enable,
  rggen_register_if.register  register_if,
  rggen_bit_field_if.register bit_field_if
);
  logic access_match;

  always_comb begin
    access_match  =
      ((register_if.access inside {RGGEN_POSTED_WRITE, RGGEN_WRITE}) && i_write_enable) ||
      ((register_if.access inside {RGGEN_READ}) && i_read_enable);
  end

  rggen_register_common #(
    .READABLE       (1              ),
    .WRITABLE       (1              ),
    .ADDRESS_WIDTH  (ADDRESS_WIDTH  ),
    .OFFSET_ADDRESS (OFFSET_ADDRESS ),
    .BUS_WIDTH      (BUS_WIDTH      ),
    .DATA_WIDTH     (DATA_WIDTH     ),
    .VALUE_WIDTH    (VALUE_WIDTH    )
  ) u_register_common (
    .i_clk              (i_clk        ),
    .i_rst_n            (i_rst_n      ),
    .register_if        (register_if  ),
    .i_additional_match (access_match ),
    .bit_field_if       (bit_field_if )
  );
endmodule
