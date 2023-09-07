module rice_core_register_file
  import  rice_riscv_pkg::*;
#(
  parameter int   XLEN      = 32,
  parameter type  EX_RESULT = logic
)(
  input   var             i_clk,
  input   var EX_RESULT   i_ex_result,
  output  var [XLEN-1:0]  o_rf[RICE_RISCV_RF_SIZE]
);
  logic [XLEN-1:0]  rf[RICE_RISCV_RF_SIZE];

  always_comb begin
    for (int i = 0;i < RICE_RISCV_RF_SIZE;++i) begin
      if (i == 0) begin
        o_rf[i] = XLEN'(0);
      end
      else begin
        o_rf[i] = rf[i];
      end
    end
  end

  function automatic logic is_writable(EX_RESULT ex_result);
    return ex_result.valid && (ex_result.rd != rice_riscv_rd'(0)) && (ex_result.error == '0);
  endfunction

  always_ff @(posedge i_clk) begin
    if (is_writable(i_ex_result)) begin
      rf[i_ex_result.rd]  <= i_ex_result.rd_value;
    end
  end
endmodule
