class tb_rice_bus_memory extends tvip_memory #(
  .ADDRESS_WIDTH  (TB_RICE_BUS_MAX_ADDRESS_WIDTH  ),
  .DATA_WIDTH     (TB_RICE_BUS_MAX_DATA_WIDTH     )
);
  function void set_configuration(tb_rice_bus_configuration configuration);
    byte_width  = configuration.data_width / 8;
  endfunction

  `tue_object_default_constructor(tb_rice_bus_memory)
  `uvm_object_utils(tb_rice_bus_memory)
endclass

class tb_rice_bus_status extends tue_status;
  tb_rice_bus_memory  memory;
  `tue_object_default_constructor(tb_rice_bus_status)
  `uvm_object_utils(tb_rice_bus_status)
endclass
