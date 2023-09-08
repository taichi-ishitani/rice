module rice_core_branch_predctor
  import  rice_riscv_pkg::*,
          rice_core_pkg::*;
#(
  parameter int   XLEN          = 32,
  parameter int   PHT_ENTRIES   = 128,
  parameter int   BTB_ENTRIES   = 128,
  parameter type  BP_RESULT     = logic,
  parameter type  BRANCH_RESULT = logic
)(
  input   var               i_clk,
  input   var               i_rst_n,
  input   var               i_enable,
  input   var BRANCH_RESULT i_branch_result,
  input   var [XLEN-1:0]    i_pc,
  output  var BP_RESULT     o_bp_result
);
  localparam  int PHT_INDEX_WIDTH = $clog2(PHT_ENTRIES);
  localparam  int BTB_INDEX_WIDTH = $clog2(BTB_ENTRIES);
  localparam  int BTB_TAG_WIDTH   = XLEN - BTB_INDEX_WIDTH - 2;

  typedef logic [1:0] rice_core_pht_entry;

  typedef struct packed {
    logic                     valid;
    logic [BTB_TAG_WIDTH-1:0] tag;
    logic [XLEN-1:0]          target_pc;
  } rice_core_btb_entry;

  rice_core_pht_entry [PHT_ENTRIES-1:0] pht;
  logic [1:0][PHT_INDEX_WIDTH-1:0]      pht_index;
  rice_core_pht_entry                   pht_entry;
  rice_core_btb_entry [BTB_ENTRIES-1:0] btb;
  logic [1:0][BTB_INDEX_WIDTH]          btb_index;
  rice_core_btb_entry                   btb_entry;

//--------------------------------------------------------------
//  Pattern history table
//--------------------------------------------------------------
  always_comb begin
    pht_index[0]  = i_pc[2+:PHT_INDEX_WIDTH];
    pht_index[1]  = i_branch_result.pc[2+:PHT_INDEX_WIDTH];
    pht_entry     = pht[pht_index[0]];
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      pht <= '{default: rice_core_pht_entry'(0)};
    end
    else if (!i_enable) begin
      pht <= '{default: rice_core_pht_entry'(0)};
    end
    else if (i_branch_result.taken || i_branch_result.not_taken) begin
      pht[pht_index[1]] <= update_pht(i_branch_result, pht[pht_index[1]]);
    end
  end

  function automatic rice_core_pht_entry update_pht(
    BRANCH_RESULT       branch_result,
    rice_core_pht_entry pht
  );
    if (branch_result.taken && (pht < rice_core_pht_entry'(3))) begin
      return pht + rice_core_pht_entry'(1);
    end
    else if (branch_result.not_taken && (pht > rice_core_pht_entry'(0))) begin
      return pht - rice_core_pht_entry'(1);
    end
    else begin
      return pht;
    end
  endfunction

//--------------------------------------------------------------
//  Branch target buffer
//--------------------------------------------------------------
  always_comb begin
    btb_index[0]  = i_pc[2+:BTB_INDEX_WIDTH];
    btb_index[1]  = i_branch_result.pc[2+:BTB_INDEX_WIDTH];
    btb_entry     = btb[btb_index[0]];
  end

  always_ff @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
      btb <= '{default: '0};
    end
    else if (!i_enable) begin
      btb <= '{default: '0};
    end
    else if (i_branch_result.taken) begin
      btb[btb_index[1]].valid     <= '1;
      btb[btb_index[1]].tag       <= i_branch_result.pc[XLEN-1-:BTB_TAG_WIDTH];
      btb[btb_index[1]].target_pc <= i_branch_result.target_pc;
    end
  end

//--------------------------------------------------------------
//  Prediction
//--------------------------------------------------------------
  always_comb begin
    o_bp_result = get_bp_result(i_pc, pht_entry, btb_entry);
  end

  function automatic BP_RESULT get_bp_result(
    logic [XLEN-1:0]    pc,
    rice_core_pht_entry pht_entry,
    rice_core_btb_entry btb_entry
  );
    BP_RESULT                 result;
    logic [BTB_TAG_WIDTH-1:0] tag;
    tag               = pc[XLEN-1-:BTB_TAG_WIDTH];
    result.taken      = btb_entry.valid && (btb_entry.tag == tag) && (pht_entry >= rice_core_pht_entry'(2));
    result.target_pc  = btb_entry.target_pc;
    return result;
  endfunction
endmodule
