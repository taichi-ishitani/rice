module rggen_rice_bit_field_counter
  import  rggen_rtl_pkg::*;
#(
  parameter int             WIDTH         = 8,
  parameter bit [WIDTH-1:0] INITIAL_VALUE = '0
)(
  input   var                   i_clk,
  input   var                   i_rst_n,
  rggen_bit_field_if.bit_field  bit_field_if,
  input   var                   i_disable,
  input   var                   i_up,
  output  var [WIDTH-1:0]       o_count
);
  logic             write;
  logic [WIDTH-1:0] write_data;
  logic [WIDTH-1:0] count;

  always_comb begin
    bit_field_if.read_data  = count;
    bit_field_if.value      = count;
    o_count                 = count;
  end

  always_comb begin
    write       = bit_field_if.valid && (bit_field_if.write_mask != '0);
    write_data  = (bit_field_if.write_data & bit_field_if.write_mask)
                | (count                   & (~bit_field_if.write_mask));
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      count <= INITIAL_VALUE;
    end
    else if (write) begin
      count <= write_data;
    end
    else if ((!i_disable) && i_up) begin
      count <= count + WIDTH'(1);
    end
  end
endmodule
