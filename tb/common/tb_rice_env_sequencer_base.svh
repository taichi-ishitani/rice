class tb_rice_env_sequencer_base #(
  type  CONFIGURATION = uvm_object,
  type  STATUS        = uvm_object
) extends tue_sequencer #(
  .CONFIGURATION  (CONFIGURATION  ),
  .STATUS         (STATUS         )
);
  `tue_component_default_constructor(tb_rice_env_sequencer_base)
endclass
