module rice_core (
  input var           i_clk,
  input var           i_rst_n,
  input var           i_enable,
  rice_bus_if.master  inst_bus_if,
  rice_bus_if.master  data_bus_if
);
  localparam  int XLEN    = 32;
  localparam  int CSR_AW  = rice_riscv_pkg::RICE_RISCV_CSR_ADDRESS_WIDTH;

  rice_core_pipeline_if #(XLEN)     pipeline_if();
  rice_bus_if #(XLEN, XLEN)         inst_if();
  rice_bus_if #(XLEN, XLEN)         data_if();
  rice_core_env_if #(XLEN)          env_if();
  rice_bus_if #(CSR_AW, XLEN, XLEN) csr_if();

  rice_bus_connector u_isnt_bus_connector (
    .slave_if   (inst_if      ),
    .master_if  (inst_bus_if  )
  );

  rice_bus_connector u_data_bus_connector (
    .slave_if   (data_if      ),
    .master_if  (data_bus_if  )
  );

  rice_core_if_stage #(
    .XLEN (XLEN )
  ) u_if_stage (
    .i_clk        (i_clk        ),
    .i_rst_n      (i_rst_n      ),
    .i_enable     (i_enable     ),
    .pipeline_if  (pipeline_if  ),
    .inst_bus_if  (inst_if      )
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
    .data_bus_if  (data_if      ),
    .csr_if       (csr_if       )
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
