class tb_rice_env_base #(
  type  CONFIGURATION = uvm_object,
  type  STATUS        = uvm_object,
  type  SEQUENCER     = uvm_sequencer
) extends tue_env #(
  .CONFIGURATION  (CONFIGURATION  ),
  .STATUS         (STATUS         )
);
  SEQUENCER sequencer;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer = SEQUENCER::type_id::create("sequencer", this);
    sequencer.set_context(configuration, status);
    create_sub_env();
    create_checker();
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    connect_sub_env();
    connect_checker();
  endfunction

  protected virtual function void create_sub_env();
  endfunction

  protected virtual function void connect_sub_env();
  endfunction

  protected virtual function void create_checker();
  endfunction

  protected virtual function void connect_checker();
  endfunction

  `tue_component_default_constructor(tb_rice_env_base)
endclass
