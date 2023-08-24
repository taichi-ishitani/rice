class tb_rice_core_env extends tb_rice_env_base #(
  .CONFIGURATION  (tb_rice_core_env_configuration ),
  .STATUS         (tb_rice_core_env_status        ),
  .SEQUENCER      (tb_rice_core_env_sequencer     )
);
  tb_rice_bus_slave_agent           inst_bus_agent;
  tb_rice_bus_slave_agent           data_bus_agent;
  tb_rice_core_env_pipeline_monitor pipeline_monitor;
  tb_rice_core_env_pipeline_tracer  pipeline_tracer;
  tb_rice_core_env_cosim_monitor    cosim_monitor;

  protected function void create_sub_env();
    inst_bus_agent  = tb_rice_bus_slave_agent::type_id::create("inst_bus_agent", this);
    inst_bus_agent.set_context(configuration.inst_bus_cfg, status.inst_bus_status);

    data_bus_agent  = tb_rice_bus_slave_agent::type_id::create("data_bus_agent", this);
    data_bus_agent.set_context(configuration.data_bus_cfg, status.data_bus_status);

    pipeline_monitor  = tb_rice_core_env_pipeline_monitor::type_id::create("pipeline_monitor", this);
    pipeline_monitor.set_context(configuration, status);

    if (configuration.pipeline_trace_file.len() > 0) begin
      pipeline_tracer = tb_rice_core_env_pipeline_tracer::type_id::create("pipeline_tracer", this);
      pipeline_tracer.set_context(configuration, status);
    end

    if (configuration.enable_cosim) begin
      cosim_monitor = tb_rice_core_env_cosim_monitor::type_id::create("cosim_monitor", this);
      cosim_monitor.set_context(configuration, status);
    end
  endfunction

  protected function void connect_sub_env();
    sequencer.inst_bus_sequencer  = inst_bus_agent.sequencer;
    sequencer.data_bus_sequencer  = data_bus_agent.sequencer;
    if (pipeline_tracer != null) begin
      pipeline_monitor.sub_monitors.push_back(pipeline_tracer);
    end
    if (cosim_monitor != null) begin
      pipeline_monitor.sub_monitors.push_back(cosim_monitor);
    end
  endfunction

  `tue_component_default_constructor(tb_rice_core_env)
  `uvm_component_utils(tb_rice_core_env)
endclass
