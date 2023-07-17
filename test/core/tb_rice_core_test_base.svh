class tb_rice_core_test_base extends tb_rice_env_test_base #(
  .CONTEXT        (tb_rice_core_env_context       ),
  .CONFIGURATION  (tb_rice_core_env_configuration ),
  .STATUS         (tb_rice_core_env_status        ),
  .ENV            (tb_rice_core_env               ),
  .SEQUENCER      (tb_rice_core_env_sequencer     )
);
  `tue_component_default_constructor(tb_rice_core_test_base)
endclass
