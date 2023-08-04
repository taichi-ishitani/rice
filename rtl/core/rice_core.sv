module rice_core (
  input var           i_clk,
  input var           i_rst_n,
  input var           i_enable,
  rice_bus_if.master  inst_bus_if,
  rice_bus_if.master  data_bus_if
);
  localparam  int XLEN  = 32;

  rice_core_pipeline_if #(XLEN) pipeline_if();
  rice_core_env_if #(XLEN)      env_if();
  rice_bus_if #(12, XLEN)       csr_if();

  rice_core_if_stage #(
    .XLEN (XLEN )
  ) u_if_stage (
    .i_clk        (i_clk        ),
    .i_rst_n      (i_rst_n      ),
    .i_enable     (i_enable     ),
    .pipeline_if  (pipeline_if  ),
    .inst_bus_if  (inst_bus_if  )
  );

  rice_core_id_stage #(
    .XLEN (XLEN )
  ) u_id_stage (
    .i_clk        (i_clk        ),
    .i_rst_n      (i_rst_n      ),
    .i_enable     (i_enable     ),
    .pipeline_if  (pipeline_if  )
  );

  rice_core_ex_stage #(
    .XLEN (XLEN )
  ) u_ex_stage (
    .i_clk        (i_clk        ),
    .i_rst_n      (i_rst_n      ),
    .i_enable     (i_enable     ),
    .pipeline_if  (pipeline_if  ),
    .env_if       (env_if       ),
    .data_bus_if  (data_bus_if  ),
    .csr_if       (csr_if       )
  );

  rice_core_register_file #(
    .XLEN (XLEN )
  ) u_register_file (
    .i_clk        (i_clk        ),
    .pipeline_if  (pipeline_if  )
  );

  rice_core_env #(
    .XLEN (XLEN )
  ) u_env (
    .i_clk    (i_clk    ),
    .i_rst_n  (i_rst_n  ),
    .i_enable (i_enable ),
    .env_if   (env_if   ),
    .csr_if   (csr_if   )
  );
endmodule
