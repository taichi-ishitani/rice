package tb_rice_bus_pkg;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tvip_common_pkg::*;

  `include  "uvm_macros.svh"
  `include  "tue_macros.svh"

  localparam  int TB_RICE_BUS_MAX_ADDRESS_WIDTH = 64;
  localparam  int TB_RICE_BUS_MAX_DATA_WIDTH    = 64;

  typedef virtual tb_rice_bus_if                  tb_rice_bus_vif;
  typedef bit [TB_RICE_BUS_MAX_ADDRESS_WIDTH-1:0] tb_rice_bus_address;
  typedef bit [TB_RICE_BUS_MAX_DATA_WIDTH/8-1:0]  tb_rice_bus_strobe;
  typedef bit [TB_RICE_BUS_MAX_DATA_WIDTH-1:0]    tb_rice_bus_data;

  `include  "tb_rice_bus_configuration.svh"
  `include  "tb_rice_bus_status.svh"
  `include  "tb_rice_bus_item.svh"
  `include  "tb_rice_bus_item_waiter.svh"
  `include  "tb_rice_bus_component_base.svh"
  `include  "tb_rice_bus_monitor_base.svh"
  `include  "tb_rice_bus_sequencer_base.svh"
  `include  "tb_rice_bus_sequence_base.svh"
  `include  "tb_rice_bus_slave_monitor.svh"
  `include  "tb_rice_bus_slave_driver.svh"
  `include  "tb_rice_bus_slave_sequencer.svh"
  `include  "tb_rice_bus_slave_data_monitor.svh"
  `include  "tb_rice_bus_slave_agent.svh"
  `include  "tb_rice_bus_slave_sequence.svh"
  `include  "tb_rice_bus_slave_default_sequence.svh"
endpackage
