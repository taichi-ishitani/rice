class tb_rice_env_context_base extends uvm_object;
  tvip_clock_vif  clock_vif;
  time            clock_period_ns;
  tvip_reset_vif  reset_vif;
  time            reset_duration_ns;

  function new(string name = "tb_rice_env_context_base");
    super.new(name);
    clock_period_ns   = 1;
    reset_duration_ns = 10;
  endfunction
endclass

class tb_rice_env_configuration_base #(
  type  CONTEXT = uvm_object
) extends tue_configuration;
  CONTEXT tb_context;

  function void post_randomize();
    super.post_randomize();
    create_sub_cfg();
  endfunction

  virtual function void set_tb_context(CONTEXT tb_context);
    this.tb_context = tb_context;
  endfunction

  protected virtual function void create_sub_cfg();
  endfunction

  `tue_object_default_constructor(tb_rice_env_configuration_base)
endclass
