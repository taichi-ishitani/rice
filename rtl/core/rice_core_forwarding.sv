module rice_core_forwarding
  import  rice_riscv_pkg::*,
          rice_core_pkg::*;
#(
  parameter int   XLEN      = 32,
  parameter type  ID_RESULT = logic,
  parameter type  EX_RESULT = logic
)(
  input   var           i_clk,
  input   var           i_rst_n,
  input   var           i_enable,
  input   var           i_stall,
  input   var ID_RESULT i_id_result,
  input   var EX_RESULT i_ex_result,
  output  var ID_RESULT o_id_result
);
  EX_RESULT wb_result;

  function automatic logic [XLEN-1:0] get_rs_value(
    rice_riscv_rs     rs,
    logic [XLEN-1:0]  rs_value,
    EX_RESULT         wb_result,
    EX_RESULT         ex_result
  );
    logic [1:0] fw;
    fw[0] = ex_result.valid && (ex_result.error == '0) && (rs == ex_result.rd) && (rs != rice_riscv_rs'(0));
    fw[1] = wb_result.valid && (wb_result.error == '0) && (rs == wb_result.rd) && (rs != rice_riscv_rs'(0));
    case (1'b1)
      fw[0]:    return ex_result.rd_value;
      fw[1]:    return wb_result.rd_value;
      default:  return rs_value;
    endcase
  endfunction

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      wb_result <= EX_RESULT'(0);
    end
    else if (!i_enable) begin
      wb_result <= EX_RESULT'(0);
    end
    else if (!i_stall) begin
      wb_result <= i_ex_result;
    end
  end

  always_comb begin
    o_id_result           = i_id_result;
    o_id_result.rs1_value = get_rs_value(i_id_result.rs1, i_id_result.rs1_value, wb_result, i_ex_result);
    o_id_result.rs2_value = get_rs_value(i_id_result.rs2, i_id_result.rs2_value, wb_result, i_ex_result);
  end
endmodule
