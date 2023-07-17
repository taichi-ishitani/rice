class tb_rice_bus_slave_default_sequence extends tb_rice_bus_slave_sequence;
  task body();
    tb_rice_bus_slave_item  item;
    forever begin
      get_request(item);
      item.data = get_read_data(item.address);
      `uvm_send(item)
    end
  endtask

  protected virtual function tb_rice_bus_data get_read_data(tb_rice_bus_address address);
    int byte_size = configuration.data_width / 8;
    return status.memory.get(byte_size, address, 0);
  endfunction

  `tue_object_default_constructor(tb_rice_bus_slave_default_sequence)
  `uvm_object_utils(tb_rice_bus_slave_default_sequence)
endclass
