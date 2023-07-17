class tb_rice_bus_slave_data_monitor extends tue_subscriber #(
  .CONFIGURATION  (tb_rice_bus_configuration  ),
  .STATUS         (tb_rice_bus_status         ),
  .T              (tb_rice_bus_item           )
);
  function void write(tb_rice_bus_item t);
    if (t.is_write()) begin
      status.memory.put(
        t.data,
        t.strobe,
        configuration.data_width / 8,
        t.address,
        0
      );
    end
  endfunction

  `tue_component_default_constructor(tb_rice_bus_slave_data_monitor)
  `uvm_component_utils(tb_rice_bus_slave_data_monitor)
endclass
