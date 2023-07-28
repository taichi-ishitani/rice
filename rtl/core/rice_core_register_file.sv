module rice_core_register_file
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input var                 i_clk,
  rice_core_pipeline_if.rf  pipeline_if
);
  `rice_core_define_types(XLEN)

  rice_core_value [31:0]  register_file;
  rice_core_exe_result    exe_result;

  always_comb begin
    pipeline_if.register_file = register_file;
  end

  always_comb begin
    exe_result  = pipeline_if.exe_result;
  end

  for (genvar i = 0;i < 32;++i) begin : g_register_file
    if (i == 0) begin : g
      always_comb begin
        register_file[i]  = '0;
      end
    end
    else begin : g
      logic update_rg;

      always_comb begin
        update_rg = exe_result.valid && (exe_result.rd == rice_core_rd'(i));
      end

      always_ff @(posedge i_clk) begin
        if (update_rg) begin
          register_file[i]  <= exe_result.rd_value;
        end
      end
    end
  end
endmodule
