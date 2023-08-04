module rice_core_env
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input var         i_clk,
  input var         i_rst_n,
  rice_bus_if.slave csr_if
);
  logic                   csr_select;
  rice_bus_if #(12, XLEN) csr_demux_if[2]();

//--------------------------------------------------------------
//  CSR
//--------------------------------------------------------------
  always_comb begin
    case (csr_if.address) inside
      [12'h300:12'h3FF],  //  Machine lavel standard rw
      [12'h700:12'h79F],  //  Machine lavel standard rw
      [12'h7A0:12'h7AF],  //  Machine lavel standard rw debug
      [12'hB00:12'hBBF],  //  Machine lavel standard rw
      [12'hF00:12'hFBF]:  //  Machine lavel standard read only
        csr_select  = 1'd1;
      default:
        csr_select  = 1'd0;
    endcase
  end

  rice_bus_demux #(
    .ADDRESS_WIDTH    (12   ),
    .DATA_WIDTH       (XLEN ),
    .NON_POSTED_WRITE (1    ),
    .MASTERS          (2    )
  ) u_csrbus_demux (
    .i_clk      (i_clk        ),
    .i_rst_n    (i_rst_n      ),
    .i_select   (csr_select   ),
    .slave_if   (csr_if       ),
    .master_if  (csr_demux_if )
  );

  rice_bus_slave_dummy #(
    .DATA_WIDTH       (XLEN ),
    .NON_POSTED_WRITE (1    ),
    .ERROR            (1    )
  ) u_csrbus_slave_dummy (
    .i_clk    (i_clk            ),
    .i_rst_n  (i_rst_n          ),
    .slave_if (csr_demux_if[0]  )
  );

  rice_csr_m_level_xlen32 #(
    .ERROR_STATUS   (1  ),
    .INSERT_SLICER  (1  )
  ) u_csr_m_level (
    .i_clk                        (i_clk            ),
    .i_rst_n                      (i_rst_n          ),
    .csr_if                       (csr_demux_if[1]  ),
    .i_mhartid                    ('0               ),
    .i_mstatus_mie_set            ('0               ),
    .i_mstatus_mie                ('0               ),
    .o_mstatus_mie                (),
    .i_mstatus_mpie_set           ('0               ),
    .i_mstatus_mpie               ('0               ),
    .o_mstatus_mpie               (),
    .i_mstatus_mpp_set            ('0               ),
    .i_mstatus_mpp                ('0               ),
    .o_mstatus_mpp                (),
    .o_misa_support_i             (),
    .o_mtvec_mode                 (),
    .o_mtvec_base                 (),
    .o_mscratch                   (),
    .i_mepc_set                   ('0               ),
    .i_mepc                       ('0               ),
    .o_mepc                       (),
    .i_mcause_exception_code_set  ('0               ),
    .i_mcause_exception_code      ('0               ),
    .o_mcause_exception_code      (),
    .i_mcause_interrupt_set       ('0               ),
    .i_mcause_interrupt           ('0               ),
    .o_mcause_interrupt           (),
    .i_mtval_set                  ('0               ),
    .i_mtval                      ('0               ),
    .o_mtval                      ()
  );
endmodule
