module rice_core_csr_rw_unit
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input   var                       i_clk,
  input   var                       i_rst_n,
  input   var                       i_valid,
  input   var rice_core_rs          i_rs1,
  input   var [XLEN-1:0]            i_rs1_value,
  input   var [XLEN-1:0]            i_imm_value,
  input   var rice_core_csr_access  i_csr_access,
  output  var                       o_access_done,
  output  var [XLEN-1:0]            o_read_data,
  output  var                       o_error,
  rice_bus_if.master                csr_if
);
  typedef enum logic [1:0] {
    IDLE,
    DO_WRITE,
    DO_READ
  } rice_core_state;

  rice_core_state   state;
  logic             write_only;
  logic             read_only;
  logic             request_valid;
  logic             start_request;
  logic [XLEN-1:0]  write_data;
  logic             access_done;

//--------------------------------------------------------------
//  FSM
//--------------------------------------------------------------
  always_comb begin
    case (i_csr_access)
      RICE_CORE_CSR_ACCESS_RW,
      RICE_CORE_CSR_ACCESS_RWI: write_only  = '1;
      RICE_CORE_CSR_ACCESS_RS,
      RICE_CORE_CSR_ACCESS_RC:  write_only  = i_rs1_value == '1;
      default:                  write_only  = '0;
    endcase

    case (i_csr_access)
      RICE_CORE_CSR_ACCESS_RS,
      RICE_CORE_CSR_ACCESS_RC:  read_only = i_rs1_value == '0;
      RICE_CORE_CSR_ACCESS_RSI,
      RICE_CORE_CSR_ACCESS_RCI: read_only = i_rs1 == '0;
      default:                  read_only = '0;
    endcase
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      state <= IDLE;
    end
    else begin
      case (state)
        IDLE: begin
          if (i_valid && write_only) begin
            state <= DO_WRITE;
          end
          else if (i_valid) begin
            state <= DO_READ;
          end
        end
        DO_READ: begin
          if (csr_if.response_ack()) begin
            if (read_only || csr_if.error) begin
              state <= IDLE;
            end
            else begin
              state <= DO_WRITE;
            end
          end
        end
        DO_WRITE: begin
          if (csr_if.response_ack()) begin
            state <= IDLE;
          end
        end
      endcase
    end
  end

//--------------------------------------------------------------
//  Request
//--------------------------------------------------------------
  always_comb begin
    csr_if.request_valid  = request_valid;
    csr_if.address        = i_imm_value[11:0];
    csr_if.strobe         = (state == DO_WRITE) ? '1 : '0;
    csr_if.write_data     = write_data;
  end

  always_comb begin
    start_request =
      ((state == IDLE) && i_valid) ||
      ((state == DO_READ) && csr_if.response_ack() && (!(csr_if.error || read_only)));
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      request_valid <= '0;
    end
    else if (csr_if.request_ack()) begin
      request_valid <= '0;
    end
    else if (start_request) begin
      request_valid <= '1;
    end
  end

  always_ff @(posedge i_clk) begin
    if ((i_valid && write_only) || csr_if.response_ack()) begin
      write_data  <=
        get_write_data(
          i_csr_access, write_only,
          i_rs1, i_rs1_value, csr_if.read_data
        );
    end
  end

  function automatic logic [XLEN-1:0] get_write_data(
    rice_core_csr_access  csr_access,
    logic                 write_only,
    rice_core_rs          rs1,
    logic [XLEN-1:0]      rs1_value,
    logic [XLEN-1:0]      read_data
  );
    logic [XLEN-1:0]  data[2];

    case (csr_access)
      RICE_CORE_CSR_ACCESS_RWI,
      RICE_CORE_CSR_ACCESS_RSI,
      RICE_CORE_CSR_ACCESS_RCI: data[0] = XLEN'(rs1);
      default:                  data[0] = rs1_value;
    endcase

    if (write_only) begin
      data[1] = '0;
    end
    else begin
      data[1] = read_data;
    end

    case (csr_access)
      RICE_CORE_CSR_ACCESS_RC,
      RICE_CORE_CSR_ACCESS_RCI: return data[1] & (~data[0]);
      default:                  return data[1] | data[0];
    endcase
  endfunction

//--------------------------------------------------------------
//  Response
//--------------------------------------------------------------
  always_comb begin
    csr_if.response_ready = (state != IDLE) && (!request_valid);
    o_access_done         = access_done;
    o_read_data           = csr_if.read_data;
    o_error               = csr_if.error;
  end

  always_comb begin
    access_done =
      csr_if.response_ack() &&
      (read_only || (state == DO_WRITE) || csr_if.error);
  end
endmodule
