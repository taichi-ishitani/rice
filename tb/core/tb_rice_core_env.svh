class tb_rice_core_env extends tb_rice_env_base #(
  .CONFIGURATION  (tb_rice_core_env_configuration ),
  .STATUS         (tb_rice_core_env_status        ),
  .SEQUENCER      (tb_rice_core_env_sequencer     )
);
  tb_rice_bus_slave_agent           inst_bus_agent;
  tb_rice_bus_slave_agent           data_bus_agent;
  tb_rice_core_env_pipeline_monitor pipeline_monitor;

  protected function void create_sub_env();
    inst_bus_agent  = tb_rice_bus_slave_agent::type_id::create("inst_bus_agent", this);
    inst_bus_agent.set_context(configuration.inst_bus_cfg, status.inst_bus_status);
    data_bus_agent  = tb_rice_bus_slave_agent::type_id::create("data_bus_agent", this);
    data_bus_agent.set_context(configuration.data_bus_cfg, status.data_bus_status);
    if (configuration.pipeline_trace_file.len() > 0) begin
      pipeline_monitor  = tb_rice_core_env_pipeline_monitor::type_id::create("pipeline_monitor", this);
      pipeline_monitor.set_context(configuration, status);
    end
  endfunction

  protected function void connect_sub_env();
    sequencer.inst_bus_sequencer  = inst_bus_agent.sequencer;
    sequencer.data_bus_sequencer  = data_bus_agent.sequencer;
  endfunction

  `tue_component_default_constructor(tb_rice_core_env)
  `uvm_component_utils(tb_rice_core_env)
endclass
