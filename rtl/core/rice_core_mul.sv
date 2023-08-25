module rice_core_mul
  import  rice_core_pkg::*;
#(
  parameter int XLEN        = 32,
  parameter int PARALLELISM = 4
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
  localparam  int SUB_MULTIPLIER_WIDTH    = XLEN / PARALLELISM;
  localparam  int SUB_MULTIPLIER_WIDTH_2  = XLEN / 2;
  localparam  int SUB_MULTIPLIER_WIDTH_4  = XLEN / 4;
  localparam  int SUB_MULTIPLIER_WIDTH_8  = XLEN / 8;
  localparam  int MULTIPLIER_FF_WIDTH     = SUB_MULTIPLIER_WIDTH + 1;
  localparam  int MULTIPLIER_WIDTH        = SUB_MULTIPLIER_WIDTH + 2;   //  +2 is for sign
  localparam  int SUM_WIDTH               = XLEN + 2;                   //  +2 is for x2 and sign
  localparam  int PRODUCT_WIDTH           = SUM_WIDTH + MULTIPLIER_WIDTH;
  localparam  int RESULT_WIDTH            = PRODUCT_WIDTH + MULTIPLIER_WIDTH
                                          + (SUB_MULTIPLIER_WIDTH * (PARALLELISM - 1));
  localparam  int TOTAL_CYCLES            = (MULTIPLIER_WIDTH / 2) + 1;
  localparam  int COUNT_WIDTH             = $clog2(TOTAL_CYCLES + 1);

  logic [COUNT_WIDTH-1:0]           count;
  logic                             start;
  logic                             last;
  logic [7:0][MULTIPLIER_WIDTH-1:0] multiplier;
  logic [7:0][PRODUCT_WIDTH-1:0]    product;

  always_comb begin
    o_result_valid  = last;
    o_result        = calc_result(i_mul_operation, product);
  end

  always_comb begin
    start = i_valid && (count == COUNT_WIDTH'(0));
    last  = i_valid && (count == COUNT_WIDTH'(1));
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      count <= COUNT_WIDTH'(0);
    end
    else if (start) begin
      count <= COUNT_WIDTH'(TOTAL_CYCLES - 1);
    end
    else if (i_valid) begin
      count <= count - COUNT_WIDTH'(1);
    end
  end

  for (genvar i = 0;i < PARALLELISM;++i) begin : g
    logic [MULTIPLIER_FF_WIDTH-1:0] multiplier_latch;
    logic [PRODUCT_WIDTH-1:0]       product_latch;

    always_comb begin
      if (start) begin
        multiplier[i] = {i_rs2_value[SUB_MULTIPLIER_WIDTH*i+:SUB_MULTIPLIER_WIDTH], 1'(0)};
      end
      else begin
        multiplier[i] = multiplier_latch;
      end
    end

    always_ff @(posedge i_clk, negedge i_rst_n) begin
      if (!i_rst_n) begin
        multiplier_latch  <= '0;
      end
      else if (i_valid) begin
        if (((i + 1) == PARALLELISM) && is_rs2_signed(i_mul_operation)) begin
          multiplier_latch  <=
            {{2{multiplier[i][MULTIPLIER_FF_WIDTH-1]}}, multiplier[i][MULTIPLIER_FF_WIDTH-1:2]};
        end
        else begin
          multiplier_latch  <=
            {2'(0), multiplier[i][MULTIPLIER_FF_WIDTH-1:2]};
        end
      end
    end

    always_comb begin
      if (start) begin
        product[i]  = PRODUCT_WIDTH'(0);
      end
      else begin
        product[i]  = product_latch;
      end
    end

    always_ff @(posedge i_clk) begin
      if (i_valid) begin
        product_latch <=
          calc_product(
            i_mul_operation, i_rs1_value, multiplier[i], product[i]
          );
      end
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
    rice_core_mul_operation         mul_operation,
    logic [XLEN-1:0]                rs1_value,
    logic [MULTIPLIER_FF_WIDTH-1:0] multiplier,
    logic [PRODUCT_WIDTH-1:0]       product
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

  function automatic logic [XLEN-1:0] calc_result(
    rice_core_mul_operation         mul_operation,
    logic [7:0][PRODUCT_WIDTH-1:0]  product
  );
    logic signed  [RESULT_WIDTH-1:0]  result;

    case (PARALLELISM)
      1: begin
        result  = product[0];
      end
      2: begin
        result  = RESULT_WIDTH'({{RESULT_WIDTH-(1*SUB_MULTIPLIER_WIDTH_2){product[0][PRODUCT_WIDTH-1]}}, product[0]})
                + RESULT_WIDTH'({{RESULT_WIDTH-(2*SUB_MULTIPLIER_WIDTH_2){product[1][PRODUCT_WIDTH-1]}}, product[1], (1*SUB_MULTIPLIER_WIDTH_2)'(0)});
      end
      4: begin
        result  = RESULT_WIDTH'({{RESULT_WIDTH-(1*SUB_MULTIPLIER_WIDTH_4){product[0][PRODUCT_WIDTH-1]}}, product[0]})
                + RESULT_WIDTH'({{RESULT_WIDTH-(2*SUB_MULTIPLIER_WIDTH_4){product[1][PRODUCT_WIDTH-1]}}, product[1], (1*SUB_MULTIPLIER_WIDTH_4)'(0)})
                + RESULT_WIDTH'({{RESULT_WIDTH-(3*SUB_MULTIPLIER_WIDTH_4){product[2][PRODUCT_WIDTH-1]}}, product[2], (2*SUB_MULTIPLIER_WIDTH_4)'(0)})
                + RESULT_WIDTH'({{RESULT_WIDTH-(4*SUB_MULTIPLIER_WIDTH_4){product[3][PRODUCT_WIDTH-1]}}, product[3], (3*SUB_MULTIPLIER_WIDTH_4)'(0)});
      end
      default: begin
        result  = RESULT_WIDTH'({{RESULT_WIDTH-(1*SUB_MULTIPLIER_WIDTH_8){product[0][PRODUCT_WIDTH-1]}}, product[0]})
                + RESULT_WIDTH'({{RESULT_WIDTH-(2*SUB_MULTIPLIER_WIDTH_8){product[1][PRODUCT_WIDTH-1]}}, product[1], (1*SUB_MULTIPLIER_WIDTH_8)'(0)})
                + RESULT_WIDTH'({{RESULT_WIDTH-(3*SUB_MULTIPLIER_WIDTH_8){product[2][PRODUCT_WIDTH-1]}}, product[2], (2*SUB_MULTIPLIER_WIDTH_8)'(0)})
                + RESULT_WIDTH'({{RESULT_WIDTH-(4*SUB_MULTIPLIER_WIDTH_8){product[3][PRODUCT_WIDTH-1]}}, product[3], (3*SUB_MULTIPLIER_WIDTH_8)'(0)})
                + RESULT_WIDTH'({{RESULT_WIDTH-(5*SUB_MULTIPLIER_WIDTH_8){product[4][PRODUCT_WIDTH-1]}}, product[4], (4*SUB_MULTIPLIER_WIDTH_8)'(0)})
                + RESULT_WIDTH'({{RESULT_WIDTH-(6*SUB_MULTIPLIER_WIDTH_8){product[5][PRODUCT_WIDTH-1]}}, product[5], (5*SUB_MULTIPLIER_WIDTH_8)'(0)})
                + RESULT_WIDTH'({{RESULT_WIDTH-(7*SUB_MULTIPLIER_WIDTH_8){product[6][PRODUCT_WIDTH-1]}}, product[6], (6*SUB_MULTIPLIER_WIDTH_8)'(0)})
                + RESULT_WIDTH'({{RESULT_WIDTH-(8*SUB_MULTIPLIER_WIDTH_8){product[7][PRODUCT_WIDTH-1]}}, product[7], (7*SUB_MULTIPLIER_WIDTH_8)'(0)});
      end
    endcase

    if (is_rd_high(mul_operation)) begin
      return result[1*XLEN+:XLEN];
    end
    else begin
      return result[0*XLEN+:XLEN];
    end
  endfunction
endmodule
