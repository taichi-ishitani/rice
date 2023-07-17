typedef tue_reactive_sequence #(
  .CONFIGURATION  (tb_rice_bus_configuration  ),
  .STATUS         (tb_rice_bus_status         ),
  .ITEM           (tb_rice_bus_slave_item     ),
  .REQUEST        (tb_rice_bus_slave_item     )
) tb_rice_bus_slave_sequence_base;

class tb_rice_bus_slave_sequence extends tb_rice_bus_sequence_base #(
  .BASE       (tb_rice_bus_slave_sequence_base  ),
  .ITEM       (tb_rice_bus_slave_item           ),
  .SEQUENCER  (tb_rice_bus_slave_sequencer      )
);
  `tue_object_default_constructor(tb_rice_bus_slave_sequence)
endclass
