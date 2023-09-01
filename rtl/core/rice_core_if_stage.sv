module rice_core_if_stage
  import  rice_riscv_pkg::*,
          rice_core_pkg::*;
#(
  parameter int             XLEN        = 32,
  parameter int             FIFO_DEPTH  = 4,
  parameter bit [XLEN-1:0]  INITIAL_PC  = XLEN'(32'h8000_0000)
)(
  input var                       i_clk,
  input var                       i_rst_n,
  input var                       i_enable,
  rice_core_pipeline_if.if_stage  pipeline_if,
  rice_bus_if.master              inst_bus_if
);
  `rice_core_define_types(XLEN)

  localparam  int COUNT_WIDTH = $clog2(FIFO_DEPTH + 1);

  rice_core_pc  [1:0]       pc;
  logic                     request_ack;
  logic                     response_ack;
  logic                     fifo_empty;
  logic                     fifo_full;
  logic                     fifo_push;
  logic                     fifo_pop;
  rice_core_pc              pc_fetched;
  rice_riscv_inst           inst;
  logic                     flush;
  logic                     flush_busy;
  logic                     flush_done;
  logic [COUNT_WIDTH-1:0]   flush_count;
  logic [COUNT_WIDTH-1:0]   flush_count_next;
  logic [COUNT_WIDTH-1:0]   count;
  rice_bus_if #(XLEN, XLEN) bus_if();

//--------------------------------------------------------------
//  Request
//--------------------------------------------------------------
  always_comb begin
    bus_if.request_valid  = i_enable && ((!fifo_full) || (!pipeline_if.stall));
    bus_if.address        = pc[0];
    bus_if.strobe         = '0;
    bus_if.write_data     = '0;
  end

  always_comb begin
    request_ack = bus_if.request_ack();
  end

  always_comb begin
    if (pipeline_if.flush) begin
      pc[0] = pipeline_if.flush_pc;
    end
    else begin
      pc[0] = pc[1];
    end
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      pc[1] <= INITIAL_PC;
    end
    else if (!i_enable) begin
      pc[1] <= INITIAL_PC;
    end
    else if (request_ack) begin
      pc[1] <= pc[0] + rice_core_pc'(4);
    end
    else if (pipeline_if.flush) begin
      pc[1] <= pipeline_if.flush_pc;
    end
  end

//--------------------------------------------------------------
//  Response
//--------------------------------------------------------------
  always_comb begin
    bus_if.response_ready = '1;
  end

  always_comb begin
    pipeline_if.if_result.valid = !fifo_empty;
    pipeline_if.if_result.pc    = pc_fetched;
    pipeline_if.if_result.inst  = inst;
  end

  always_comb begin
    response_ack  = bus_if.response_ack();
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      pc_fetched  <= INITIAL_PC;
    end
    else if (!i_enable) begin
      pc_fetched  <= INITIAL_PC;
    end
    else if (pipeline_if.flush) begin
      pc_fetched  <= pipeline_if.flush_pc;
    end
    else if (fifo_pop) begin
      pc_fetched  <= pc_fetched + rice_core_pc'(4);
    end
  end

  always_comb begin
    fifo_push = bus_if.response_valid;
    fifo_pop  = pipeline_if.if_result.valid && (!pipeline_if.stall);
  end

  pzbcm_fifo #(
    .TYPE       (rice_riscv_inst  ),
    .DEPTH      (FIFO_DEPTH       ),
    .THRESHOLD  (FIFO_DEPTH - 2   )
  ) u_inst_fifo (
    .i_clk          (i_clk            ),
    .i_rst_n        (i_rst_n          ),
    .i_clear        (flush            ),
    .o_empty        (fifo_empty       ),
    .o_almost_full  (fifo_full        ),
    .o_full         (),
    .o_word_count   (),
    .i_push         (fifo_push        ),
    .i_data         (bus_if.read_data ),
    .i_pop          (fifo_pop         ),
    .o_data         (inst             )
  );

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
    .master_if  (inst_bus_if  )
  );

//--------------------------------------------------------------
//  Flush control
//--------------------------------------------------------------
  always_comb begin
    flush_busy  = flush_count != COUNT_WIDTH'(0);
    flush       = pipeline_if.flush || flush_busy;
  end

  always_comb begin
    case ({pipeline_if.flush, flush_busy, response_ack}) inside
      3'b1?1:   flush_count_next  = count - COUNT_WIDTH'(1);
      3'b1?0:   flush_count_next  = count;
      3'b011:   flush_count_next  = flush_count - COUNT_WIDTH'(1);
      default:  flush_count_next  = flush_count;
    endcase
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      flush_count <= COUNT_WIDTH'(0);
    end
    else if (pipeline_if.flush || response_ack) begin
      flush_count <= flush_count_next;
    end
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      count <= COUNT_WIDTH'(0);
    end
    else if ({request_ack, response_ack} == 2'b10) begin
      count <= count + COUNT_WIDTH'(1);
    end
    else if ({request_ack, response_ack} == 2'b01) begin
      count <= count - COUNT_WIDTH'(1);
    end
  end
endmodule
