class tb_rice_core_env_sequencer extends tb_rice_env_sequencer_base #(
  .CONFIGURATION  (tb_rice_core_env_configuration ),
  .STATUS         (tb_rice_core_env_status        )
);
  tb_rice_bus_slave_sequencer inst_bus_sequencer;
  tb_rice_bus_slave_sequencer data_bus_sequencer;

  `tue_component_default_constructor(tb_rice_core_env_sequencer)
  `uvm_component_utils(tb_rice_core_env_sequencer)
endclass
