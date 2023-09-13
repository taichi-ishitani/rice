module rice_core_csr_rw_unit
  import  rice_riscv_pkg::*,
          rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input   var                       i_clk,
  input   var                       i_rst_n,
  input   var                       i_valid,
  input   var rice_riscv_rs         i_rs1,
  input   var [XLEN-1:0]            i_rs1_value,
  input   var [XLEN-1:0]            i_imm_value,
  input   var rice_core_csr_access  i_csr_access,
  output  var                       o_access_done,
  output  var [XLEN-1:0]            o_read_data,
  output  var                       o_error,
  rice_bus_if.master                csr_if
);
  localparam  int AW  = RICE_RISCV_CSR_ADDRESS_WIDTH;

  logic                         request_done;
  rice_bus_if #(AW, XLEN, XLEN) bus_if();

  //  Request
  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      request_done  <= '0;
    end
    else if (bus_if.response_ack()) begin
      request_done  <= '0;
    end
    else if (bus_if.request_ack()) begin
      request_done  <= '1;
    end
  end

  always_comb begin
    bus_if.request_valid  = i_valid && (!request_done);
    bus_if.address        = i_imm_value[AW-1:0];
    bus_if.strobe         = get_strobe(i_csr_access, i_rs1, i_rs1_value);
    bus_if.write_data     = get_write_data(i_csr_access, i_rs1, i_rs1_value);
  end

  function automatic logic [XLEN-1:0] get_strobe(
    rice_core_csr_access  csr_access,
    rice_riscv_rs         rs1,
    logic [XLEN-1:0]      rs1_value
  );
    case (csr_access)
      RICE_CORE_CSR_ACCESS_RW,
      RICE_CORE_CSR_ACCESS_RWI: return '1;
      default:                  return select_data(csr_access, rs1, rs1_value);
    endcase
  endfunction

  function automatic logic [XLEN-1:0] get_write_data(
    rice_core_csr_access  csr_access,
    rice_riscv_rs         rs1,
    logic [XLEN-1:0]      rs1_value
  );
    case (csr_access)
      RICE_CORE_CSR_ACCESS_RS,
      RICE_CORE_CSR_ACCESS_RSI: return '1;
      RICE_CORE_CSR_ACCESS_RC,
      RICE_CORE_CSR_ACCESS_RCI: return '0;
      default:                  return select_data(csr_access, rs1, rs1_value);
    endcase
  endfunction

  function automatic logic [XLEN-1:0] select_data(
    rice_core_csr_access  csr_access,
    rice_riscv_rs         rs1,
    logic [XLEN-1:0]      rs1_value
  );
    case (csr_access)
      RICE_CORE_CSR_ACCESS_RWI,
      RICE_CORE_CSR_ACCESS_RSI,
      RICE_CORE_CSR_ACCESS_RCI: return XLEN'(rs1);
      default:                  return rs1_value;
    endcase
  endfunction

  //  Response
  always_comb begin
    bus_if.response_ready = request_done;
    o_access_done         = bus_if.response_ack();
    o_read_data           = bus_if.read_data;
    o_error               = bus_if.error;
  end

  //  Slicer
  rice_bus_slicer #(
    .ADDRESS_WIDTH    (AW   ),
    .DATA_WIDTH       (XLEN ),
    .STROBE_WIDTH     (XLEN ),
    .REQUEST_STAGES   (1    ),
    .RESPONSE_STAGES  (0    ),
    .FULL_BANDWIDTH   (0    )
  ) u_bus_slicer (
    .i_clk      (i_clk    ),
    .i_rst_n    (i_rst_n  ),
    .slave_if   (bus_if   ),
    .master_if  (csr_if   )
  );
endmodule
