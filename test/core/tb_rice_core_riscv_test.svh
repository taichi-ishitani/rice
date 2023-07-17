class tb_rice_core_riscv_test extends tb_riscv_test_base #(
  .BASE (tb_rice_core_test_base )
);
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    inst_bus_sequencer  = sequencer.inst_bus_sequencer;
    data_bus_sequencer  = sequencer.data_bus_sequencer;
  endfunction

  `tue_component_default_constructor(tb_rice_core_riscv_test)
  `uvm_component_utils(tb_rice_core_riscv_test)
endclass
