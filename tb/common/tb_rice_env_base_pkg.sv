package tb_rice_env_base_pkg;
  timeunit  1ns;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tvip_common_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  `include  "tb_rice_env_configuration_base.svh"
  `include  "tb_rice_env_status_base.svh"
  `include  "tb_rice_env_sequencer_base.svh"
  `include  "tb_rice_env_base.svh"
  `include  "tb_rice_env_test_base.svh"

  task automatic run_uvm_test(uvm_object tb_context);
    $timeformat(-9, 3, "ns");
    uvm_config_db #(uvm_object)::set(null, "", "tb_context", tb_context);
    run_test();
  endtask
endpackage
