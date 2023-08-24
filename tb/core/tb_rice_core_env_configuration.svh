class tb_rice_core_env_context extends tb_rice_env_context_base;
  tb_rice_bus_vif                       inst_bus_vif;
  tb_rice_bus_vif                       data_bus_vif;
  tb_rice_core_env_pipeline_monitor_vif pipeline_monitor_vif;
  `tue_object_default_constructor(tb_rice_core_env_context)
  `uvm_object_utils(tb_rice_core_env_context)
endclass

class tb_rice_core_env_configuration extends tb_rice_env_configuration_base #(
  .CONTEXT  (tb_rice_core_env_context )
);
  tb_rice_bus_configuration inst_bus_cfg;
  tb_rice_bus_configuration data_bus_cfg;
  string                    pipeline_trace_file;
  bit                       enable_cosim;

  protected function void parse_plugargs();
    super.parse_plugargs();
    `tue_define_plusarg_string(+pipeline_trace_file, pipeline_trace_file)
    `tue_define_plusarg_flag(+enable_cosim, enable_cosim)
  endfunction

  protected function void create_sub_cfg();
    inst_bus_cfg  = create_bus_cfg("inst_bus_cfg", tb_context.inst_bus_vif);
    data_bus_cfg  = create_bus_cfg("data_bus_cfg", tb_context.data_bus_vif);
  endfunction

  protected function tb_rice_bus_configuration create_bus_cfg(
    string          name,
    tb_rice_bus_vif vif
  );
    tb_rice_bus_configuration cfg;
    cfg     = tb_rice_bus_configuration::type_id::create(name);
    cfg.vif = vif;
    `tue_randomize_with(cfg, {
      address_width == 32;
      data_width    == 32;
    })
    return cfg;
  endfunction

  `tue_object_default_constructor(tb_rice_core_env_configuration)
  `uvm_object_utils(tb_rice_core_env_configuration)
endclass
