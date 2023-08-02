package tb_rice_core_test_pkg;
  timeunit  1ns;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tb_rice_bus_pkg::*;
  import  tb_rice_env_base_pkg::*;
  import  tb_rice_core_env_pkg::*;
  import  tb_riscv_test_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  `include  "tb_rice_core_test_base.svh"
  `include  "tb_rice_core_basic_test_base.svh"
  `include  "tb_rice_core_basic_lw_sw_test.svh"
  `include  "tb_rice_core_basic_lui_auipc_test.svh"
  `include  "tb_rice_core_basic_add_sub_test.svh"
  `include  "tb_rice_core_basic_and_or_xor_test.svh"
  `include  "tb_rice_core_basic_sll_srl_sra_test.svh"
  `include  "tb_rice_core_basic_slt_test.svh"
  `include  "tb_rice_core_basic_beq_bne_blt_bge_test.svh"
  `include  "tb_rice_core_basic_jal_jalr_test.svh"
  `include  "tb_rice_core_riscv_test.svh"
endpackage
