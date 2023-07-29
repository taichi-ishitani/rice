class tb_rice_core_test_base extends tb_rice_env_test_base #(
  .CONTEXT        (tb_rice_core_env_context       ),
  .CONFIGURATION  (tb_rice_core_env_configuration ),
  .STATUS         (tb_rice_core_env_status        ),
  .ENV            (tb_rice_core_env               ),
  .SEQUENCER      (tb_rice_core_env_sequencer     )
);
  protected function void setup_default_sequences();
    set_default_sequence(
      tb_rice_bus_slave_default_sequence::type_id::get(),
      "run_phase", sequencer.inst_bus_sequencer
    );
    set_default_sequence(
      tb_rice_bus_slave_default_sequence::type_id::get(),
      "run_phase", sequencer.data_bus_sequencer
    );
  endfunction

  `tue_component_default_constructor(tb_rice_core_test_base)
endclass
