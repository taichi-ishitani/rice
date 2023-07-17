class tb_rice_bus_slave_agent extends tue_reactive_agent #(
  .CONFIGURATION            (tb_rice_bus_configuration    ),
  .STATUS                   (tb_rice_bus_status           ),
  .ITEM                     (tb_rice_bus_item             ),
  .MONITOR                  (tb_rice_bus_slave_monitor    ),
  .SEQUENCER                (tb_rice_bus_slave_sequencer  ),
  .DRIVER                   (tb_rice_bus_slave_driver     ),
  .ENABLE_PASSIVE_SEQUENCER (1                            )
);
  protected tb_rice_bus_slave_data_monitor  data_monitor;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (status.memory == null) begin
      status.memory = tb_rice_bus_memory::type_id::create("memory");
      status.memory.set_configuration(configuration);
    end

    data_monitor  = tb_rice_bus_slave_data_monitor::type_id::create("data_monitor", this);
    data_monitor.set_context(configuration, status);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    monitor.item_port.connect(sequencer.item_export);
    monitor.item_port.connect(data_monitor.analysis_export);
  endfunction

  `tue_component_default_constructor(tb_rice_bus_slave_agent)
  `uvm_component_utils(tb_rice_bus_slave_agent)
endclass
