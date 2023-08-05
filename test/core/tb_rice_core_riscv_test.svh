class tb_rice_core_riscv_test extends tb_riscv_test_base #(
  .BASE (tb_rice_core_test_base )
);
  protected tb_rice_bus_memory  memory;

  protected function void create_status();
    super.create_status();
    memory  = tb_rice_bus_memory::type_id::create("memory");
    memory.set_configuration(configuration.inst_bus_cfg);
    status.inst_bus_status.memory = memory;
    status.data_bus_status.memory = memory;
  endfunction

  protected function void put_word_data(
    tb_rice_bus_address address,
    bit [31:0]          word_data
  );
    memory.put(word_data, 4'hF, 4, address, 0);
  endfunction

  protected task get_data_bus_item(ref tb_rice_bus_item item);
    sequencer.data_bus_sequencer.get_item(item);
  endtask

  `tue_component_default_constructor(tb_rice_core_riscv_test)
  `uvm_component_utils(tb_rice_core_riscv_test)
endclass
