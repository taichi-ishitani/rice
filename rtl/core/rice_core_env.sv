module rice_core_env
  import  rice_riscv_pkg::*,
          rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input var             i_clk,
  input var             i_rst_n,
  input var             i_enable,
  rice_core_env_if.env  env_if,
  rice_bus_if.slave     csr_if
);
  `rice_core_define_types(XLEN)

  localparam  int EXCEPTION_CODE_WIDTH  = XLEN - 1;
  localparam  int MTVEC_BASE_LSB        = 2;
  localparam  int MTVEC_BASE_WIDTH      = XLEN - MTVEC_BASE_LSB;

  rice_core_privilege_level         privilege_level;
  logic                             do_trap;
  logic                             do_return;
  logic                             cycle_en;
  logic                             instret_en;
  logic                             mie_set;
  logic [1:0]                       mie;
  logic                             mpie_set;
  logic [1:0]                       mpie;
  logic [MTVEC_BASE_WIDTH-1:0]      mtvec_base;
  logic                             mcounteren_cy;
  logic                             mcounteren_ir;
  logic                             mpp_set;
  logic [1:0][1:0]                  mpp;
  logic                             mepc_set;
  rice_core_pc  [1:0]               mepc;
  logic                             mcause_set;
  logic                             mcause_interrutpt;
  logic [EXCEPTION_CODE_WIDTH-1:0]  mcause_code;
  logic [1:0]                       mcycle_up;
  logic [2*XLEN-1:0]                mcycle;
  logic [1:0]                       minstret_up;
  logic [2*XLEN-1:0]                minstret;
  logic [1:0]                       csr_select;
  rice_bus_if #(12, XLEN)           csr_demux_if[3]();

//--------------------------------------------------------------
//  Privilege level
//--------------------------------------------------------------
  always_comb begin
    env_if.privilege_level  = privilege_level;
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      privilege_level <= RICE_CORE_MACHINE_MODE;
    end
    else if (!i_enable) begin
      privilege_level <= RICE_CORE_MACHINE_MODE;
    end
    else if (do_trap) begin
      privilege_level <= RICE_CORE_MACHINE_MODE;
    end
    else if (do_return) begin
      privilege_level <= rice_core_privilege_level'(mpp[0]);
    end
  end

//--------------------------------------------------------------
//  Trap control
//--------------------------------------------------------------
  always_comb begin
    env_if.trap_pc    = {mtvec_base, MTVEC_BASE_LSB'(0)};
    env_if.return_pc  = mepc[0];
  end

  always_comb begin
    do_trap   = env_if.exception != '0;
    do_return = env_if.mret;
  end

  always_comb begin
    mie_set   = do_trap || do_return;
    mpie_set  = mie_set;
    mpp_set   = mie_set;
    if (do_return) begin
      mie[1]  = mpie[0];
      mpie[1] = '1;
      mpp[1]  = RICE_CORE_MACHINE_MODE;
    end
    else begin
      mie[1]  = '0;
      mpie[1] = mie[0];
      mpp[1]  = privilege_level;
    end
  end

  always_comb begin
    mepc_set          = do_trap;
    mepc[1]           = env_if.pc;
    mcause_set        = do_trap;
    mcause_interrutpt = '0;
    mcause_code       = get_exception_code(env_if.exception);
  end

  function automatic logic [EXCEPTION_CODE_WIDTH-1:0] get_exception_code(
    rice_core_exception exception
  );
    for (int i = 0;i < $bits(rice_core_exception);++i) begin
      if (exception[i]) begin
        return EXCEPTION_CODE_WIDTH'(i);
      end
    end

    return EXCEPTION_CODE_WIDTH'(0);
  endfunction

//--------------------------------------------------------------
//  Machine counter
//--------------------------------------------------------------
  always_comb begin
    if (privilege_level == RICE_CORE_MACHINE_MODE) begin
      cycle_en    = '1;
      instret_en  = '1;
    end
    else begin
      cycle_en    = mcounteren_cy;
      instret_en  = mcounteren_ir;
    end
  end

  always_comb begin
    mcycle_up[0]  = i_enable;
    mcycle_up[1]  = mcycle_up[0] && (mcycle[0*XLEN+:XLEN] == '1);
  end

  always_comb begin
    minstret_up[0]  = i_enable && env_if.inst_retired;
    minstret_up[1]  = minstret_up[0] && (minstret[0*XLEN+:XLEN] == '1);
  end

//--------------------------------------------------------------
//  CSR
//--------------------------------------------------------------
  always_comb begin
    case (csr_if.address) inside
      [12'h000:12'h0FF],  //  User level standard rw
      [12'h400:12'h4FF],  //  User level standard rw
      [12'hC00:12'hCBF]:  //  User level standard read only
        csr_select  = 2'd0;
      [12'h300:12'h3FF],  //  Machine lavel standard rw
      [12'h700:12'h79F],  //  Machine lavel standard rw
      [12'h7A0:12'h7AF],  //  Machine lavel standard rw debug
      [12'hB00:12'hBBF],  //  Machine lavel standard rw
      [12'hF00:12'hFBF]:  //  Machine lavel standard read only
        csr_select  = (privilege_level == RICE_CORE_MACHINE_MODE) ? 2'd1 : 2'd2;
      default:
        csr_select  = 2'd2;
    endcase
  end

  rice_bus_demux #(
    .ADDRESS_WIDTH    (12   ),
    .DATA_WIDTH       (XLEN ),
    .NON_POSTED_WRITE (1    ),
    .MASTERS          (3    )
  ) u_csrbus_demux (
    .i_clk      (i_clk        ),
    .i_rst_n    (i_rst_n      ),
    .i_select   (csr_select   ),
    .slave_if   (csr_if       ),
    .master_if  (csr_demux_if )
  );

  rice_csr_u_level_xlen32 #(
    .ERROR_STATUS   (1  ),
    .INSERT_SLICER  (1  )
  ) u_csr_u_level (
    .i_clk                    (i_clk                  ),
    .i_rst_n                  (i_rst_n                ),
    .csr_if                   (csr_demux_if[0]        ),
    .i_cycle_write_enable     ('0                     ),
    .i_cycle_read_enable      (cycle_en               ),
    .i_cycle                  (mcycle[0*XLEN+:XLEN]   ),
    .i_instret_write_enable   ('0                     ),
    .i_instret_read_enable    (instret_en             ),
    .i_instret                (minstret[0*XLEN+:XLEN] ),
    .i_cycleh_write_enable    ('0                     ),
    .i_cycleh_read_enable     (cycle_en               ),
    .i_cycleh                 (mcycle[1*XLEN+:XLEN]   ),
    .i_instreth_write_enable  ('0                     ),
    .i_instreth_read_enable   (instret_en             ),
    .i_instreth               (minstret[1*XLEN+:XLEN] )
  );

  rice_csr_m_level_xlen32 #(
    .ERROR_STATUS   (1  ),
    .INSERT_SLICER  (1  )
  ) u_csr_m_level (
    .i_clk                        (i_clk                  ),
    .i_rst_n                      (i_rst_n                ),
    .csr_if                       (csr_demux_if[1]        ),
    .i_mhartid                    ('0                     ),
    .i_mstatus_mie_set            (mie_set                ),
    .i_mstatus_mie                (mie[1]                 ),
    .o_mstatus_mie                (mie[0]                 ),
    .i_mstatus_mpie_set           (mpie_set               ),
    .i_mstatus_mpie               (mpie[1]                ),
    .o_mstatus_mpie               (mpie[0]                ),
    .i_mstatus_mpp_set            (mpp_set                ),
    .i_mstatus_mpp                (mpp[1]                 ),
    .o_mstatus_mpp                (mpp[0]                 ),
    .o_mtvec_mode                 (),
    .o_mtvec_base                 (mtvec_base             ),
    .o_mcounteren_cy              (mcounteren_cy          ),
    .o_mcounteren_ir              (mcounteren_ir          ),
    .o_mscratch                   (),
    .i_mepc_set                   (mepc_set               ),
    .i_mepc                       (mepc[1]                ),
    .o_mepc                       (mepc[0]                ),
    .i_mcause_exception_code_set  (mcause_set             ),
    .i_mcause_exception_code      (mcause_code            ),
    .o_mcause_exception_code      (),
    .i_mcause_interrupt_set       (mcause_set             ),
    .i_mcause_interrupt           (mcause_interrutpt      ),
    .o_mcause_interrupt           (),
    .i_mtval_set                  ('0                     ),
    .i_mtval                      ('0                     ),
    .o_mtval                      (),
    .i_mcycle_up                  (mcycle_up[0]           ),
    .o_mcycle_count               (mcycle[0*XLEN+:XLEN]   ),
    .i_minstret_up                (minstret_up[0]         ),
    .o_minstret_count             (minstret[0*XLEN+:XLEN] ),
    .i_mcycleh_up                 (mcycle_up[1]           ),
    .o_mcycleh_count              (mcycle[1*XLEN+:XLEN]   ),
    .i_minstreth_up               (minstret_up[1]         ),
    .o_minstreth_count            (minstret[1*XLEN+:XLEN] ),
    .o_mcountinhibit_cy           (),
    .o_mcountinhibit_ir           ()
  );

  rice_bus_slave_dummy #(
    .DATA_WIDTH       (XLEN ),
    .NON_POSTED_WRITE (1    ),
    .ERROR            (1    )
  ) u_csrbus_slave_dummy (
    .i_clk    (i_clk            ),
    .i_rst_n  (i_rst_n          ),
    .slave_if (csr_demux_if[2]  )
  );
endmodule
