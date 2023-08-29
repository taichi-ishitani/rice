`ifndef rggen_connect_bit_field_if
  `define rggen_connect_bit_field_if(RIF, FIF, LSB, WIDTH) \
  assign  FIF.valid                 = RIF.valid; \
  assign  FIF.read_mask             = RIF.read_mask[LSB+:WIDTH]; \
  assign  FIF.write_mask            = RIF.write_mask[LSB+:WIDTH]; \
  assign  FIF.write_data            = RIF.write_data[LSB+:WIDTH]; \
  assign  RIF.read_data[LSB+:WIDTH] = FIF.read_data; \
  assign  RIF.value[LSB+:WIDTH]     = FIF.value;
`endif
`ifndef rggen_tie_off_unused_signals
  `define rggen_tie_off_unused_signals(WIDTH, VALID_BITS, RIF) \
  if (1) begin : __g_tie_off \
    genvar  __i; \
    for (__i = 0;__i < WIDTH;++__i) begin : g \
      if ((((VALID_BITS) >> __i) % 2) == 0) begin : g \
        assign  RIF.read_data[__i]  = 1'b0; \
        assign  RIF.value[__i]      = 1'b0; \
      end \
    end \
  end
`endif
module rice_csr_u_level_xlen32
  import rggen_rtl_pkg::*;
#(
  parameter int ADDRESS_WIDTH = 14,
  parameter bit PRE_DECODE = 0,
  parameter bit [ADDRESS_WIDTH-1:0] BASE_ADDRESS = '0,
  parameter bit ERROR_STATUS = 0,
  parameter bit [31:0] DEFAULT_READ_DATA = '0,
  parameter bit INSERT_SLICER = 0
)(
  input logic i_clk,
  input logic i_rst_n,
  rice_bus_if.slave csr_if,
  input logic i_cycle_write_enable,
  input logic i_cycle_read_enable,
  input logic [31:0] i_cycle,
  input logic i_instret_write_enable,
  input logic i_instret_read_enable,
  input logic [31:0] i_instret,
  input logic i_cycleh_write_enable,
  input logic i_cycleh_read_enable,
  input logic [31:0] i_cycleh,
  input logic i_instreth_write_enable,
  input logic i_instreth_read_enable,
  input logic [31:0] i_instreth
);
  rggen_register_if #(14, 32, 32) register_if[4]();
  rggen_rice_bus_if_adapter #(
    .ADDRESS_WIDTH        (ADDRESS_WIDTH),
    .LOCAL_ADDRESS_WIDTH  (14),
    .BUS_WIDTH            (32),
    .REGISTERS            (4),
    .PRE_DECODE           (PRE_DECODE),
    .BASE_ADDRESS         (BASE_ADDRESS),
    .BYTE_SIZE            (16384),
    .ERROR_STATUS         (ERROR_STATUS),
    .DEFAULT_READ_DATA    (DEFAULT_READ_DATA),
    .INSERT_SLICER        (INSERT_SLICER)
  ) u_adaper (
    .i_clk        (i_clk),
    .i_rst_n      (i_rst_n),
    .csr_if       (csr_if),
    .register_if  (register_if)
  );
  generate if (1) begin : g_cycle
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'hffffffff, bit_field_if)
    rggen_rice_register_variable_access #(
      .ADDRESS_WIDTH  (14),
      .OFFSET_ADDRESS (14'h3000),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk          (i_clk),
      .i_rst_n        (i_rst_n),
      .i_write_enable (i_cycle_write_enable),
      .i_read_enable  (i_cycle_read_enable),
      .register_if    (register_if[0]),
      .bit_field_if   (bit_field_if)
    );
    if (1) begin : g_cycle
      rggen_bit_field_if #(32) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 32)
      rggen_bit_field #(
        .WIDTH              (32),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_cycle),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_instret
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'hffffffff, bit_field_if)
    rggen_rice_register_variable_access #(
      .ADDRESS_WIDTH  (14),
      .OFFSET_ADDRESS (14'h3008),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk          (i_clk),
      .i_rst_n        (i_rst_n),
      .i_write_enable (i_instret_write_enable),
      .i_read_enable  (i_instret_read_enable),
      .register_if    (register_if[1]),
      .bit_field_if   (bit_field_if)
    );
    if (1) begin : g_instret
      rggen_bit_field_if #(32) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 32)
      rggen_bit_field #(
        .WIDTH              (32),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_instret),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_cycleh
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'hffffffff, bit_field_if)
    rggen_rice_register_variable_access #(
      .ADDRESS_WIDTH  (14),
      .OFFSET_ADDRESS (14'h3200),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk          (i_clk),
      .i_rst_n        (i_rst_n),
      .i_write_enable (i_cycleh_write_enable),
      .i_read_enable  (i_cycleh_read_enable),
      .register_if    (register_if[2]),
      .bit_field_if   (bit_field_if)
    );
    if (1) begin : g_cycleh
      rggen_bit_field_if #(32) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 32)
      rggen_bit_field #(
        .WIDTH              (32),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_cycleh),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_instreth
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'hffffffff, bit_field_if)
    rggen_rice_register_variable_access #(
      .ADDRESS_WIDTH  (14),
      .OFFSET_ADDRESS (14'h3208),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk          (i_clk),
      .i_rst_n        (i_rst_n),
      .i_write_enable (i_instreth_write_enable),
      .i_read_enable  (i_instreth_read_enable),
      .register_if    (register_if[3]),
      .bit_field_if   (bit_field_if)
    );
    if (1) begin : g_instreth
      rggen_bit_field_if #(32) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 32)
      rggen_bit_field #(
        .WIDTH              (32),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_instreth),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
endmodule
