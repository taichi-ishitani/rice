class tb_rice_core_env_status extends tb_rice_env_status_base;
  tb_rice_bus_status  inst_bus_status;
  tb_rice_bus_status  data_bus_status;

  function new(string name = "tb_rice_core_env_status");
    super.new(name);
    inst_bus_status = tb_rice_bus_status::type_id::create("inst_bus_status");
    data_bus_status = tb_rice_bus_status::type_id::create("data_bus_status");
  endfunction

  `uvm_object_utils(tb_rice_core_env_status)
endclass
