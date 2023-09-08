interface rice_core_pipeline_if
  import  rice_riscv_pkg::*,
          rice_core_pkg::*;
#(
  parameter int XLEN  = 32
);
  `rice_core_define_types(XLEN)

  rice_core_if_result     if_result;
  rice_core_id_result     id_result;
  rice_core_ex_result     ex_result;
  logic                   stall;
  logic                   flush;
  rice_core_pc            flush_pc;
  rice_core_branch_result branch_result;
  rice_core_value         rf[RICE_RISCV_RF_SIZE];

  modport if_stage (
    input   stall,
    input   flush,
    input   flush_pc,
    input   branch_result,
    output  if_result
  );

  modport id_stage (
    input   stall,
    input   flush,
    input   if_result,
    output  id_result,
    input   ex_result,
    output  rf
  );

  modport ex_stage (
    input   id_result,
    output  ex_result,
    output  stall,
    output  flush,
    output  flush_pc,
    output  branch_result
  );

  modport monitor (
    input if_result,
    input id_result,
    input ex_result,
    input rf,
    input stall,
    input flush,
    input flush_pc,
    input branch_result
  );
endinterface
