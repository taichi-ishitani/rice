module rice_core_lsu
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
)(
  input   var                         i_clk,
  input   var                         i_rst_n,
  input   var                         i_valid,
  input   var [XLEN-1:0]              i_rs1_value,
  input   var [XLEN-1:0]              i_rs2_value,
  input   var [XLEN-1:0]              i_imm_value,
  input   var rice_core_memory_access i_memory_access,
  output  var [1:0]                   o_access_done,
  output  var [XLEN-1:0]              o_read_data,
  rice_bus_if.master                  data_bus_if
);
  typedef enum logic [1:0] {
    IDLE,
    DO_1ST_ACCESS,
    DO_2ND_ACCESS,
    WAIT_FOR_DONE
  } rice_core_state;

  localparam  int BYTE_SIZE     = XLEN / 8;
  localparam  int OFFSET_WIDTH  = $clog2(BYTE_SIZE);
  localparam  int STROBE_WIDTH  = BYTE_SIZE;

  logic [XLEN-1:0]          address;
  logic [OFFSET_WIDTH-1:0]  offset;
  logic                     single_access;
  rice_core_state           request_state;
  logic                     request_start;
  logic [XLEN-1:0]          request_address;
  logic [STROBE_WIDTH-1:0]  strobe;
  logic [XLEN-1:0]          write_data;
  logic                     write_access_done;
  rice_core_state           response_state;
  logic [2*XLEN-1:0]        read_data;
  logic [XLEN-1:0]          read_data_1st;
  logic                     read_access_done;
  rice_bus_if #(XLEN, XLEN) bus_if();

  always_comb begin
    address       = i_rs1_value + i_imm_value;
    offset        = address[0+:OFFSET_WIDTH];
    single_access = is_single_access(offset, i_memory_access);
  end

  function automatic logic is_single_access(
    logic [OFFSET_WIDTH-1:0]  offset,
    rice_core_memory_access   memory_access
  );
    if (XLEN == 32) begin
      case (memory_access.access_mode)
        RICE_CORE_MEMORY_ACCESS_MODE_B,
        RICE_CORE_MEMORY_ACCESS_MODE_BU:  return '1;
        RICE_CORE_MEMORY_ACCESS_MODE_H,
        RICE_CORE_MEMORY_ACCESS_MODE_HU:  return offset != OFFSET_WIDTH'(3);
        default:                          return offset == OFFSET_WIDTH'(0);
      endcase
    end
  endfunction

//--------------------------------------------------------------
//  Request
//--------------------------------------------------------------
  always_comb begin
    bus_if.request_valid  = get_request_valid(i_valid, request_state);
    bus_if.address        = get_address(request_state, address);
    bus_if.strobe         = get_strobe(request_state, offset, i_memory_access);
    bus_if.write_data     = get_write_data(request_state, offset, i_rs2_value);
  end

  always_comb begin
    request_start = i_valid && (request_state == IDLE);
  end

  always_comb begin
    write_access_done =
      bus_if.write_request_ack() &&
      (single_access || (request_state == DO_2ND_ACCESS));
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      request_state <= IDLE;
    end
    else begin
      case (request_state)
        IDLE: begin
          if (i_valid && (!bus_if.request_ready)) begin
            request_state <= DO_1ST_ACCESS;
          end
          else if (bus_if.request_ack() && (!single_access)) begin
            request_state <= DO_2ND_ACCESS;
          end
          else if (bus_if.read_request_ack()) begin
            request_state <= WAIT_FOR_DONE;
          end
        end
        DO_1ST_ACCESS: begin
          if (bus_if.request_ack() && (!single_access)) begin
            request_state <= DO_2ND_ACCESS;
          end
          else if (bus_if.write_request_ack()) begin
            request_state <= IDLE;
          end
          else if (bus_if.read_request_ack()) begin
            request_state <= WAIT_FOR_DONE;
          end
        end
        DO_2ND_ACCESS: begin
          if (bus_if.write_request_ack()) begin
            request_state <= IDLE;
          end
          else if (bus_if.read_request_ack()) begin
            request_state <= WAIT_FOR_DONE;
          end
        end
        WAIT_FOR_DONE: begin
          if (read_access_done) begin
            request_state <= IDLE;
          end
        end
      endcase
    end
  end

  function automatic logic get_request_valid(
    logic           valid,
    rice_core_state state
  );
    return (valid && (state == IDLE)) || (state inside {DO_1ST_ACCESS, DO_2ND_ACCESS});
  endfunction

  function automatic logic [XLEN-1:0] get_address(
    rice_core_state   state,
    logic [XLEN-1:0]  address
  );
    logic [XLEN-1:0]  bus_address;

    bus_address = {address[XLEN-1:OFFSET_WIDTH], OFFSET_WIDTH'(0)};
    if (state == DO_2ND_ACCESS) begin
      bus_address = bus_address + XLEN'(BYTE_SIZE);
    end

    return bus_address;
  endfunction

  function automatic logic [STROBE_WIDTH-1:0] get_strobe(
    rice_core_state           state,
    logic [OFFSET_WIDTH-1:0]  offset,
    rice_core_memory_access   memory_access
  );
    logic [STROBE_WIDTH-1:0]    strobe_base;
    logic [2*STROBE_WIDTH-1:0]  strobe;

    case (memory_access)
      {RICE_CORE_MEMORY_ACCESS_STORE, RICE_CORE_MEMORY_ACCESS_MODE_B}:
        strobe_base = STROBE_WIDTH'('h1);
      {RICE_CORE_MEMORY_ACCESS_STORE, RICE_CORE_MEMORY_ACCESS_MODE_H}:
        strobe_base = STROBE_WIDTH'('h3);
      {RICE_CORE_MEMORY_ACCESS_STORE, RICE_CORE_MEMORY_ACCESS_MODE_W}:
        strobe_base = STROBE_WIDTH'('hF);
      default:
        strobe_base = '0;
    endcase

    case (offset)
      OFFSET_WIDTH'(0): strobe  = (2*STROBE_WIDTH)'({strobe_base});
      OFFSET_WIDTH'(1): strobe  = (2*STROBE_WIDTH)'({strobe_base, 1'(0)});
      OFFSET_WIDTH'(2): strobe  = (2*STROBE_WIDTH)'({strobe_base, 2'(0)});
      OFFSET_WIDTH'(3): strobe  = (2*STROBE_WIDTH)'({strobe_base, 3'(0)});
      OFFSET_WIDTH'(4): strobe  = (2*STROBE_WIDTH)'({strobe_base, 4'(0)});
      OFFSET_WIDTH'(5): strobe  = (2*STROBE_WIDTH)'({strobe_base, 5'(0)});
      OFFSET_WIDTH'(6): strobe  = (2*STROBE_WIDTH)'({strobe_base, 6'(0)});
      default:          strobe  = (2*STROBE_WIDTH)'({strobe_base, 7'(0)});
    endcase

    if (state == DO_2ND_ACCESS) begin
      return strobe[1*STROBE_WIDTH+:STROBE_WIDTH];
    end
    else begin
      return strobe[0*STROBE_WIDTH+:STROBE_WIDTH];
    end
  endfunction

  function automatic logic [XLEN-1:0] get_write_data(
    rice_core_state           state,
    logic [OFFSET_WIDTH-1:0]  offset,
    logic [XLEN-1:0]          rs2_value
  );
    logic [2*XLEN-1:0]  data;

    case (offset)
      OFFSET_WIDTH'(0): data  = (2*XLEN)'({rs2_value});
      OFFSET_WIDTH'(1): data  = (2*XLEN)'({rs2_value, (1*8)'(0)});
      OFFSET_WIDTH'(2): data  = (2*XLEN)'({rs2_value, (2*8)'(0)});
      OFFSET_WIDTH'(3): data  = (2*XLEN)'({rs2_value, (3*8)'(0)});
      OFFSET_WIDTH'(4): data  = (2*XLEN)'({rs2_value, (4*8)'(0)});
      OFFSET_WIDTH'(5): data  = (2*XLEN)'({rs2_value, (5*8)'(0)});
      OFFSET_WIDTH'(6): data  = (2*XLEN)'({rs2_value, (6*8)'(0)});
      default:          data  = (2*XLEN)'({rs2_value, (7*8)'(0)});
    endcase

    if (state == DO_2ND_ACCESS) begin
      return data[1*XLEN+:XLEN];
    end
    else begin
      return data[0*XLEN+:XLEN];
    end
  endfunction

//--------------------------------------------------------------
//  Response
//--------------------------------------------------------------
  always_comb begin
    bus_if.response_ready = response_state != IDLE;
  end

  always_comb begin
    read_access_done  =
      bus_if.response_ack() &&
      (single_access || (response_state == DO_2ND_ACCESS));
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      response_state  <= IDLE;
    end
    else begin
      case (response_state)
        IDLE: begin
          if (bus_if.read_request_ack()) begin
            response_state  <= DO_1ST_ACCESS;
          end
        end
        DO_1ST_ACCESS: begin
          if (bus_if.response_ack() && single_access) begin
            response_state  <= IDLE;
          end
          else if (bus_if.response_ack()) begin
            response_state  <= DO_2ND_ACCESS;
          end
        end
        DO_2ND_ACCESS: begin
          if (bus_if.response_ack()) begin
            response_state  <= IDLE;
          end
        end
      endcase
    end
  end

  always_comb begin
    if (response_state == DO_1ST_ACCESS) begin
      read_data[0*XLEN+:XLEN] = data_bus_if.read_data;
      read_data[1*XLEN+:XLEN] = data_bus_if.read_data;
    end
    else begin
      read_data[0*XLEN+:XLEN] = read_data_1st;
      read_data[1*XLEN+:XLEN] = data_bus_if.read_data;
    end
  end

  always_ff @(posedge i_clk) begin
    if (data_bus_if.response_ack()) begin
      read_data_1st <= data_bus_if.read_data;
    end
  end

//--------------------------------------------------------------
//  Slicer
//--------------------------------------------------------------
  rice_bus_slicer #(
    .ADDRESS_WIDTH    (XLEN ),
    .DATA_WIDTH       (XLEN ),
    .REQUEST_STAGES   (1    ),
    .RESPONSE_STAGES  (0    )
  ) u_slicer (
    .i_clk      (i_clk        ),
    .i_rst_n    (i_rst_n      ),
    .slave_if   (bus_if       ),
    .master_if  (data_bus_if  )
  );

//--------------------------------------------------------------
//  Result
//--------------------------------------------------------------
  always_comb begin
    o_access_done[0]  = write_access_done;
    o_access_done[1]  = read_access_done;
    o_read_data       = get_read_data(read_data, offset, i_memory_access);
  end

  function automatic logic [XLEN-1:0] get_read_data(
    logic [2*XLEN-1:0]        read_data,
    logic [OFFSET_WIDTH-1:0]  offset,
    rice_core_memory_access   memory_access
  );
    logic [XLEN-1:0]  data;
    data  = read_data[8*offset+:XLEN];
    case (memory_access.access_mode)
      RICE_CORE_MEMORY_ACCESS_MODE_B:
        return {{XLEN-7{data[7]}}, data[6:0]};
      RICE_CORE_MEMORY_ACCESS_MODE_BU:
        return XLEN'(data[7:0]);
      RICE_CORE_MEMORY_ACCESS_MODE_H:
        return {{XLEN-15{data[15]}}, data[14:0]};
      RICE_CORE_MEMORY_ACCESS_MODE_HU:
        return XLEN'(data[15:0]);
      default:
        return data;
    endcase
  endfunction
endmodule
