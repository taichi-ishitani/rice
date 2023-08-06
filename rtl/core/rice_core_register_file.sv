module rice_core_register_file
  import  rice_riscv_pkg::*,
          rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input var                 i_clk,
  rice_core_pipeline_if.rf  pipeline_if
);
  localparam  int RF_SIZE = 32;

  `rice_core_define_types(XLEN)

  rice_core_value     register_file[RF_SIZE];
  rice_core_ex_result ex_result;

  always_comb begin
    for (int i = 0;i < RF_SIZE;++i) begin
      if (i == 0) begin
        pipeline_if.register_file[i]  = rice_core_value'(0);
      end
      else begin
        pipeline_if.register_file[i]  = register_file[i];
      end
    end
  end

  always_comb begin
    ex_result = pipeline_if.ex_result;
  end

  always_ff @(posedge i_clk) begin
    if (ex_result.valid && (ex_result.rd != rice_riscv_rd'(0))) begin
      register_file[ex_result.rd] <= ex_result.rd_value;
    end
  end
endmodule
