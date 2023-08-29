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
  localparam  int DIVIDEND_WIDTH  = XLEN + 1;
  localparam  int RESULT_WIDTH    = 2 * XLEN;
  localparam  int INITIAL_COUNT   = XLEN + 1; //  xlen + output
  localparam  int COUNT_WIDTH     = $clog2(INITIAL_COUNT + 1);

  localparam  bit [XLEN-1:0]  VALUE_MIN     = {1'(1), {XLEN-1{1'b0}}};
  localparam  bit [XLEN-1:0]  VALUE_MINUS_1 = '1;

  typedef struct packed {
    logic [COUNT_WIDTH-1:0]   count;
    logic [RESULT_WIDTH-1:0]  result;
  } rice_core_div_initial_value;

  rice_core_div_initial_value initial_value;
  logic [COUNT_WIDTH-1:0]     count;
  logic                       start;
  logic                       calcuration;
  logic                       finish;
  logic [RESULT_WIDTH-1:0]    result;

  always_comb begin
    o_result_valid  = finish;
    o_result        = get_result(i_div_operation, i_rs1_value, i_rs2_value, result);
  end

  always_comb begin
    initial_value = get_initial_value(i_div_operation, i_rs1_value);
  end

  always_comb begin
    start       = i_valid && (count == COUNT_WIDTH'(0));
    calcuration = count >= COUNT_WIDTH'(2);
    finish      = count == COUNT_WIDTH'(1);
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      count <= COUNT_WIDTH'(0);
    end
    else if (start) begin
      count <= initial_value.count;
    end
    else if (i_valid) begin
      count <= count - COUNT_WIDTH'(1);
    end
  end

  always_ff @(posedge i_clk) begin
    if (start) begin
      result  <= initial_value.result;
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
    return
      is_signed(div_operation) &&
      (dividend[XLEN-1] != divisor[XLEN-1]);
  endfunction

  function automatic logic [DIVIDEND_WIDTH-1:0] extend_sign(
    rice_core_div_operation div_operation,
    logic [XLEN-1:0]        value
  );
    if (is_signed(div_operation)) begin
      return {value[XLEN-1], value};
    end
    else begin
      return DIVIDEND_WIDTH'(value);
    end
  endfunction

  function automatic rice_core_div_initial_value get_initial_value(
    rice_core_div_operation div_operation,
    logic [XLEN-1:0]        rs1_value
  );
    logic                       sign_bit;
    logic [XLEN-1:0]            match_sign;
    rice_core_div_initial_value initial_value[XLEN];
    logic [RESULT_WIDTH-1:0]    result;
    logic [COUNT_WIDTH-1:0]     count;

    sign_bit  = is_signed(div_operation) && rs1_value[XLEN-1];
    for (int i = 0;i < XLEN;++i) begin
      match_sign[i] =
        (rs1_value[i] == sign_bit) &&
        (((i + 1) < XLEN) || (rs1_value != VALUE_MIN));
    end

    for (int i = 0;i < XLEN;++i) begin
      initial_value[XLEN-(i+1)].result  = {{XLEN{sign_bit}}, XLEN'(rs1_value << i)};
      initial_value[XLEN-(i+1)].count   = COUNT_WIDTH'(INITIAL_COUNT - i);
    end

    for (int i = (XLEN - 1);i >= 1;--i) begin
      if (!match_sign[i]) begin
        return initial_value[i];
      end
    end

    return initial_value[0];
  endfunction

  function automatic logic [RESULT_WIDTH-1:0] do_division(
    rice_core_div_operation   div_operation,
    logic [XLEN-1:0]          rs2_value,
    logic [RESULT_WIDTH-1:0]  result
  );
    logic [DIVIDEND_WIDTH-1:0]  dividend;
    logic [DIVIDEND_WIDTH-1:0]  a;
    logic [DIVIDEND_WIDTH-1:0]  b;
    logic [DIVIDEND_WIDTH-1:0]  c;

    dividend  = result[RESULT_WIDTH-1-:DIVIDEND_WIDTH];
    a         = dividend;
    b         = extend_sign(div_operation, rs2_value);
    if (modify_sign(div_operation, XLEN'(a), XLEN'(b))) begin
      c = a + b;
    end
    else begin
      c = a - b;
    end

    if (needs_recovery(dividend, c)) begin
      return RESULT_WIDTH'({result, 1'(0)});
    end
    else begin
      return RESULT_WIDTH'({c, result[RESULT_WIDTH-DIVIDEND_WIDTH-1:0], 1'(1)});
    end
  endfunction

  function automatic logic needs_recovery(
    logic [DIVIDEND_WIDTH-1:0]  dividend,
    logic [DIVIDEND_WIDTH-1:0]  result
  );
    return
      (result[DIVIDEND_WIDTH-1] != dividend[DIVIDEND_WIDTH-1]) &&
      (result != DIVIDEND_WIDTH'(0));
  endfunction

  function automatic logic [XLEN-1:0] get_result(
    rice_core_div_operation   div_operation,
    logic [XLEN-1:0]          rs1_value,
    logic [XLEN-1:0]          rs2_value,
    logic [RESULT_WIDTH-1:0]  result
  );
    logic div_zero;
    logic overflow;
    logic mod_sign;
    logic div;
    logic divu;
    logic rem;
    logic remu;

    div_zero  = rs2_value == XLEN'(0);
    overflow  = is_overflow(div_operation, rs1_value, rs2_value);
    mod_sign  = modify_sign(div_operation, rs1_value, rs2_value);
    div       = div_operation.div;
    divu      = div_operation.divu;
    rem       = div_operation.rem;
    remu      = div_operation.remu;
    case ({div_zero, overflow, div, divu, rem, remu}) inside
      6'b1?1???,
      6'b1??1??:  return '1;
      6'b1???1?,
      6'b1????1:  return rs1_value;
      6'b?11???:  return rs1_value;
      6'b?1??1?:  return '0;
      6'b00??1?,
      6'b00???1:  return result[1*XLEN+:XLEN];
      default:    return (mod_sign) ? -result[0*XLEN+:XLEN] : result[0*XLEN+:XLEN];
    endcase
  endfunction

  function automatic logic is_overflow(
    rice_core_div_operation     div_operation,
    logic [XLEN-1:0]            rs1_value,
    logic [XLEN-1:0]            rs2_value
  );
    return
      is_signed(div_operation) &&
      (rs1_value == VALUE_MIN) && (rs2_value == VALUE_MINUS_1);
  endfunction
endmodule
