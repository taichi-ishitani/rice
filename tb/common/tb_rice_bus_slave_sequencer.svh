typedef tue_reactive_fifo_sequencer #(
  .CONFIGURATION  (tb_rice_bus_configuration  ),
  .STATUS         (tb_rice_bus_status         ),
  .ITEM           (tb_rice_bus_slave_item     ),
  .REQUEST        (tb_rice_bus_slave_item     ),
  .REQUEST_HANDLE (tb_rice_bus_item           )
) tb_rice_bus_slave_sequencer_base;

class tb_rice_bus_slave_sequencer extends tb_rice_bus_sequencer_base #(
  .BASE (tb_rice_bus_slave_sequencer_base )
);
  `tue_component_default_constructor(tb_rice_bus_slave_sequencer)
  `uvm_component_utils(tb_rice_bus_slave_sequencer)
endclass
