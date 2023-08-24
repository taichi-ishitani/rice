package tb_rice_core_env_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tb_rice_bus_pkg::*;
  import  tb_rice_riscv_pkg::*;
  import  tb_rice_env_base_pkg::*;
  import  tb_rice_cosim_pkg::tb_rice_cosim_proxy;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  typedef virtual tb_rice_core_env_pipeline_monitor_if
    tb_rice_core_env_pipeline_monitor_vif;

  `include  "tb_rice_core_env_configuration.svh"
  `include  "tb_rice_core_env_status.svh"
  `include  "tb_rice_core_env_pipeline_monitor.svh"
  `include  "tb_rice_core_env_pipeline_tracer.svh"
  `include  "tb_rice_core_env_cosim_monitor.svh"
  `include  "tb_rice_core_env_sequencer.svh"
  `include  "tb_rice_core_env.svh"
endpackage
