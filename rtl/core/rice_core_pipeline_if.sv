interface rice_core_pipeline_if
  import  rice_core_pkg::*;
#(
  parameter int XLEN  = 32
);
  `rice_core_define_types(XLEN)

  rice_core_if_result     if_result;
  rice_core_id_result     id_result;
  rice_core_exe_result    exe_result;
  logic                   stall;
  logic                   flush;
  rice_core_pc            flush_pc;
  rice_core_value [31:0]  register_file;

  modport if_stage (
    input   stall,
    input   flush,
    input   flush_pc,
    output  if_result
  );

  modport id_stage (
    input   stall,
    input   flush,
    input   if_result,
    output  id_result,
    input   register_file
  );

  modport exe_stage (
    input   id_result,
    output  exe_result,
    output  stall,
    output  flush,
    output  flush_pc
  );

  modport rf (
    input   exe_result,
    output  register_file
  );

  modport monitor (
    input if_result,
    input id_result,
    input exe_result,
    input register_file,
    input stall,
    input flush,
    input flush_pc
  );
endinterface
