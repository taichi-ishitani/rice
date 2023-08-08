interface tb_rice_core_env_pipeline_monitor_if
  import  rice_riscv_pkg::*,
          rice_core_pkg::*;
(
  input var i_clk,
  input var i_rst_n
);
  localparam  int XLEN  = 64;
  `rice_core_define_types(XLEN)

  bit                 inst_request_valid;
  bit                 inst_request_ack;
  bit [XLEN-1:0]      inst_request_address;
  bit                 isnt_request_issued;
  bit                 if_valid;
  rice_core_if_result if_result;
  bit                 id_valid;
  rice_core_id_result id_result;
  bit                 ex_valid;
  rice_core_ex_result ex_result;
  bit                 wb_valid;
  bit                 flush;

  clocking monitor_cb @(posedge i_clk);
    input inst_request_valid;
    input inst_request_ack;
    input inst_request_address;
    input isnt_request_issued;
    input if_valid;
    input if_result;
    input id_valid;
    input id_result;
    input ex_valid;
    input ex_result;
    input wb_valid;
    input flush;
  endclocking
endinterface
