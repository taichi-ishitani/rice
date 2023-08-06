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

  rice_core_pc            pc;
  logic                   request_valid;
  logic                   request_ack;
  logic                   response_ack;
  logic                   fifo_empty;
  logic                   fifo_almost_full;
  logic                   fifo_push;
  logic                   fifo_pop;
  rice_core_pc            pc_fetched;
  rice_riscv_inst         inst;
  logic                   flush;
  logic                   flush_busy;
  logic                   flush_done;
  logic [COUNT_WIDTH-1:0] count;

//--------------------------------------------------------------
//  Request
//--------------------------------------------------------------
  always_comb begin
    inst_bus_if.request_valid = request_valid;
    inst_bus_if.address       = pc;
    inst_bus_if.strobe        = '0;
    inst_bus_if.write_data    = '0;
  end

  always_comb begin
    request_ack = inst_bus_if.request_ack();
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      request_valid <= '0;
    end
    else if (request_ack || (!request_valid)) begin
      request_valid <=
        i_enable && (!fifo_almost_full) && ((!flush) || flush_done);
    end
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      pc  <= INITIAL_PC;
    end
    else if (!i_enable) begin
      pc  <= INITIAL_PC;
    end
    else if ((!request_valid) && pipeline_if.flush) begin
      pc  <= pipeline_if.flush_pc;
    end
    else if (request_ack) begin
      if (pipeline_if.flush) begin
        pc  <= pipeline_if.flush_pc;
      end
      else if (flush_busy) begin
        pc  <= pc_fetched;
      end
      else begin
        pc  <= pc + rice_core_pc'(4);
      end
    end
  end

//--------------------------------------------------------------
//  Response
//--------------------------------------------------------------
  always_comb begin
    inst_bus_if.response_ready  = '1;
  end

  always_comb begin
    pipeline_if.if_result.valid = !fifo_empty;
    pipeline_if.if_result.pc    = pc_fetched;
    pipeline_if.if_result.inst  = inst;
  end

  always_comb begin
    response_ack  = inst_bus_if.response_ack();
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
    fifo_push = inst_bus_if.response_valid && (!flush);
    fifo_pop  = pipeline_if.if_result.valid && (!pipeline_if.stall);
  end

  pzbcm_fifo #(
    .TYPE       (rice_riscv_inst  ),
    .DEPTH      (FIFO_DEPTH       ),
    .THRESHOLD  (FIFO_DEPTH - 2   )
  ) u_inst_fifo (
    .i_clk          (i_clk                  ),
    .i_rst_n        (i_rst_n                ),
    .i_clear        (flush                  ),
    .o_empty        (fifo_empty             ),
    .o_almost_full  (fifo_almost_full       ),
    .o_full         (),
    .o_word_count   (),
    .i_push         (fifo_push              ),
    .i_data         (inst_bus_if.read_data  ),
    .i_pop          (fifo_pop               ),
    .o_data         (inst                   )
  );

//--------------------------------------------------------------
//  Flush control
//--------------------------------------------------------------
  always_comb begin
    flush       = pipeline_if.flush || flush_busy;
    flush_done  = get_flush_done(flush, request_ack, response_ack, count);
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      flush_busy  <= '0;
    end
    else if (flush_done) begin
      flush_busy  <= '0;
    end
    else if (pipeline_if.flush) begin
      flush_busy  <= '1;
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

  function automatic logic get_flush_done(
    logic                   flush,
    logic                   request_ack,
    logic                   response_ack,
    logic [COUNT_WIDTH-1:0] count
  );
    logic [1:0] done;
    done[0] = (!request_ack) && response_ack && (count == COUNT_WIDTH'(1));
    done[1] = count == COUNT_WIDTH'(0);
    return flush && (done != '0);
  endfunction
endmodule
