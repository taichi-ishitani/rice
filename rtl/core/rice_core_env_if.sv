interface rice_core_env_if
  import  rice_riscv_pkg::*,
          rice_core_pkg::*;
#(
  parameter int XLEN  = 32
);
  `rice_core_define_types(XLEN)

  rice_core_privilege_level privilege_level;
  rice_core_pc              trap_pc;
  rice_core_pc              return_pc;
  rice_core_exception       exception;
  logic                     mret;
  rice_core_pc              pc;
  rice_riscv_inst           inst;

  modport env (
    output  privilege_level,
    output  trap_pc,
    output  return_pc,
    input   exception,
    input   mret,
    input   pc,
    input   inst
  );

  modport ex_stage (
    input   privilege_level,
    input   trap_pc,
    input   return_pc,
    output  exception,
    output  mret,
    output  pc,
    output  inst
  );

  modport monitor (
    input privilege_level,
    input trap_pc,
    input return_pc,
    input exception,
    input mret,
    input pc,
    input inst
  );
endinterface
