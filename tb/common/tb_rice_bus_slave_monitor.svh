typedef tue_reactive_monitor #(
  .CONFIGURATION  (tb_rice_bus_configuration  ),
  .STATUS         (tb_rice_bus_status         ),
  .ITEM           (tb_rice_bus_slave_item     ),
  .ITEM_HANDLE    (tb_rice_bus_item           ),
  .REQUEST        (tb_rice_bus_item           )
) tb_rice_bus_slave_monitor_base;

class tb_rice_bus_slave_monitor extends tb_rice_bus_monitor_base #(
  .BASE (tb_rice_bus_slave_monitor_base ),
  .ITEM (tb_rice_bus_slave_item         )
);
  protected function void begin_request(tb_rice_bus_item item);
    super.begin_request(item);
    write_request(item);
  endfunction

  `tue_component_default_constructor(tb_rice_bus_slave_monitor)
  `uvm_component_utils(tb_rice_bus_slave_monitor)
endclass
