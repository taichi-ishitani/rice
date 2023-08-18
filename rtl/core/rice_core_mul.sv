module rice_core_mul
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input   var                         i_clk,
  input   var                         i_rst_n,
  input   var                         i_valid,
  input   var [XLEN-1:0]              i_rs1_value,
  input   var [XLEN-1:0]              i_rs2_value,
  input   var rice_core_mul_operation i_mul_operation,
  output  var                         o_result_valid,
  output  var [XLEN-1:0]              o_result
);
  localparam  int MULTIPLIER_WIDTH  = XLEN + 1;
  localparam  int SUM_WIDTH         = XLEN + 2; //  x2 + sign
  localparam  int PRODUCT_WIDTH     = SUM_WIDTH + XLEN + 2;
  localparam  int INITIAL_COUNT     = (XLEN + 2) / 2;
  localparam  int COUNT_WIDTH       = $clog2(INITIAL_COUNT);

  logic [COUNT_WIDTH-1:0]         count;
  logic                           busy;
  logic                           start;
  logic                           last;
  logic [MULTIPLIER_WIDTH-1:0]    multiplier;
  logic [1:0][PRODUCT_WIDTH-1:0]  product;

  always_comb begin
    o_result_valid  = last;
    if (is_rd_high(i_mul_operation)) begin
      o_result  = product[0][1*XLEN+:XLEN];
    end
    else begin
      o_result  = product[0][0*XLEN+:XLEN];
    end
  end

  always_comb begin
    busy  = count != COUNT_WIDTH'(0);
    last  = count == COUNT_WIDTH'(1);
    start = i_valid && (!busy);
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      count <= COUNT_WIDTH'(0);
    end
    else if (start) begin
      count <= INITIAL_COUNT;
    end
    else if (busy) begin
      count <= count - COUNT_WIDTH'(1);
    end
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      multiplier  <= '0;
    end
    else if (start) begin
      multiplier  <= {i_rs2_value, 1'(0)};
    end
    else if (busy) begin
      if (is_rs2_signed(i_mul_operation)) begin
        multiplier  <= {{2{multiplier[MULTIPLIER_WIDTH-1]}}, multiplier[MULTIPLIER_WIDTH-1:2]};
      end
      else begin
        multiplier  <= {2'(0), multiplier[MULTIPLIER_WIDTH-1:2]};
      end
    end
  end

  always_comb begin
    product[0]  =
      calc_product(
        i_mul_operation, i_rs1_value, multiplier, product[1]
      );
  end

  always_ff @(posedge i_clk) begin
    if (start) begin
      product[1]  <= PRODUCT_WIDTH'(0);
    end
    else if (busy) begin
      product[1]  <= product[0];
    end
  end

  function automatic logic is_rd_high(rice_core_mul_operation mul_operation);
    return !mul_operation.mul;
  endfunction

  function automatic logic is_rs1_signed(rice_core_mul_operation mul_operation);
    return mul_operation.mulh || mul_operation.mulhsu;
  endfunction

  function automatic logic is_rs2_signed(rice_core_mul_operation mul_operation);
    return mul_operation.mulh;
  endfunction

  function automatic logic [PRODUCT_WIDTH-1:0] calc_product(
    rice_core_mul_operation       mul_operation,
    logic [XLEN-1:0]              rs1_value,
    logic [MULTIPLIER_WIDTH-1:0]  multiplier,
    logic [PRODUCT_WIDTH-1:0]     product
  );
    logic                     rs1_signed;
    logic [SUM_WIDTH-1:0]     a;
    logic [SUM_WIDTH-1:0]     b;
    logic [SUM_WIDTH-1:0]     c;
    logic [PRODUCT_WIDTH-1:0] product_next;

    rs1_signed  = is_rs1_signed(mul_operation);
    a           = product[PRODUCT_WIDTH-1-:SUM_WIDTH];
    case ({rs1_signed, multiplier[2:0]}) inside
      4'b0011,
      4'b0100:  b = SUM_WIDTH'({rs1_value, 1'(0)});
      4'b0?01,
      4'b0?10:  b = SUM_WIDTH'(rs1_value);
      4'b1011,
      4'b1100:  b = {rs1_value[XLEN-1], rs1_value, 1'(0)};
      4'b1?01,
      4'b1?10:  b = {{2{rs1_value[XLEN-1]}}, rs1_value};
      default:  b = SUM_WIDTH'(0);
    endcase

    if (multiplier[2]) begin
      c = a - b;
    end
    else begin
      c = a + b;
    end

    product_next  = {c, product[0+:(PRODUCT_WIDTH-SUM_WIDTH)]};
    return {{2{product_next[PRODUCT_WIDTH-1]}}, product_next[PRODUCT_WIDTH-1:2]};
  endfunction
endmodule
