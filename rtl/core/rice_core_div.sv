module rice_core_div
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input   var                         i_clk,
  input   var                         i_rst_n,
  input   var                         i_valid,
  input   var [XLEN-1:0]              i_rs1_value,
  input   var [XLEN-1:0]              i_rs2_value,
  input   var rice_core_div_operation i_div_operation,
  output  var                         o_result_valid,
  output  var [XLEN-1:0]              o_result
);
  localparam  int REMAINDER_WIDTH = 2 * XLEN;
  localparam  int COUNT_WIDTH     = $clog2(XLEN + 2);
  localparam  int INITIAL_COUNT   = XLEN + 1;
  localparam  int SUB_WIDTH       = XLEN + 1;

  typedef struct packed {
    logic [REMAINDER_WIDTH-1:0] remainder;
    logic [XLEN-1:0]            quotient;
  } rice_core_division_result;

  logic [COUNT_WIDTH-1:0]   count;
  logic                     calcuration;
  logic                     finish;
  logic                     busy;
  logic                     start;
  rice_core_division_result result;

  always_comb begin
    o_result_valid  = finish;
    o_result        = get_result(i_div_operation, i_rs1_value, i_rs2_value, result);
  end

  always_comb begin
    calcuration = count >= COUNT_WIDTH'(2);
    finish      = count == COUNT_WIDTH'(1);
    busy        = calcuration || finish;
    start       = i_valid && (!busy);
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      count <= COUNT_WIDTH'(0);
    end
    else if (start) begin
      count <= COUNT_WIDTH'(INITIAL_COUNT);
    end
    else if (busy) begin
      count <= count - COUNT_WIDTH'(1);
    end
  end

  always_ff @(posedge i_clk) begin
    if (start) begin
      result  <= get_initial_result(i_div_operation, i_rs1_value);
    end
    else if (calcuration) begin
      result  <= do_division(i_div_operation, i_rs2_value, result);
    end
  end

  function automatic logic is_signed(rice_core_div_operation div_operation);
    return div_operation.div || div_operation.rem;
  endfunction

  function automatic logic modify_sign(
    rice_core_div_operation div_operation,
    logic [XLEN-1:0]        dividend,
    logic [XLEN-1:0]        divisor
  );
    return is_signed(div_operation) && (dividend[XLEN-1] != divisor[XLEN-1]);
  endfunction

  function automatic logic [XLEN-1:0] get_result(
    rice_core_div_operation   div_operation,
    logic [XLEN-1:0]          rs1_value,
    logic [XLEN-1:0]          rs2_value,
    rice_core_division_result result
  );
    logic div_zero;
    logic overflow;
    logic div;
    logic divu;
    logic rem;
    logic remu;
    logic mod_sign;

    div_zero  = rs2_value == XLEN'(0);
    overflow  = is_signed(div_operation) && (rs1_value == {1'(1), {XLEN-1{1'(0)}}}) && (rs2_value == '1);
    div       = div_operation.div;
    divu      = div_operation.divu;
    rem       = div_operation.rem;
    remu      = div_operation.remu;
    mod_sign  = modify_sign(div_operation, rs1_value, rs2_value);
    case ({div_zero, overflow, div, divu, rem, remu}) inside
      6'b1?1???,
      6'b1??1??:  return '1;
      6'b1???1?,
      6'b1????1:  return rs1_value;
      6'b?11???:  return rs1_value;
      6'b?1??1?:  return '0;
      6'b00??1?,
      6'b00???1:  return result.remainder[REMAINDER_WIDTH-1-:XLEN];
      default:    return (mod_sign) ? -result.quotient : result.quotient;
    endcase
  endfunction

  function automatic rice_core_division_result get_initial_result(
    rice_core_div_operation div_operation,
    logic [XLEN-1:0]        rs1_value
  );
    rice_core_division_result result;

    result.quotient = XLEN'(0);
    if (is_signed(div_operation)) begin
      result.remainder  = {{XLEN{rs1_value[XLEN-1]}}, rs1_value};
    end
    else begin
      result.remainder  = REMAINDER_WIDTH'(rs1_value);
    end

    return result;
  endfunction

  function automatic rice_core_division_result do_division(
    rice_core_div_operation   div_operation,
    logic [XLEN-1:0]          rs2_value,
    rice_core_division_result current_result
  );
    logic [REMAINDER_WIDTH-1:0] remainder;
    logic [SUB_WIDTH-1:0]       a;
    logic [SUB_WIDTH-1:0]       b;
    logic [SUB_WIDTH-1:0]       c;
    rice_core_division_result   result;

    remainder = current_result.remainder;
    a         = remainder[REMAINDER_WIDTH-1-:SUB_WIDTH];
    if (is_signed(div_operation)) begin
      b = {rs2_value[XLEN-1], rs2_value};
    end
    else begin
      b = {1'(0), rs2_value};
    end

    if (modify_sign(div_operation, XLEN'(a), rs2_value)) begin
      c = a + b;
    end
    else begin
      c = a - b;
    end

    if ((c[SUB_WIDTH-1] == a[SUB_WIDTH-1]) || (c == SUB_WIDTH'(0))) begin
      result.remainder  = REMAINDER_WIDTH'({c, remainder[REMAINDER_WIDTH-SUB_WIDTH-1:0], 1'(0)});
      result.quotient   = XLEN'({current_result.quotient, 1'(1)});
    end
    else begin
      result.remainder  = REMAINDER_WIDTH'({remainder, 1'(0)});
      result.quotient   = XLEN'({current_result.quotient, 1'(0)});
    end

    return result;
  endfunction

  if (RICE_CORE_DEBUG) begin : g_debug
    logic [SUB_WIDTH-1:0] a;

    always_comb begin
      a = result.remainder[REMAINDER_WIDTH-1-:SUB_WIDTH];
    end
  end
endmodule
