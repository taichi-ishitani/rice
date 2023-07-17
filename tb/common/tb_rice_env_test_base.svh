class tb_rice_env_test_base #(
  type  CONTEXT       = uvm_object,
  type  CONFIGURATION = uvm_object,
  type  STATUS        = uvm_object,
  type  ENV           = uvm_env,
  type  SEQUENCER     = uvm_sequencer
) extends tue_test #(
  .CONFIGURATION  (CONFIGURATION  ),
  .STATUS         (STATUS         )
);
  ENV       env;
  SEQUENCER sequencer;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ENV::type_id::create("env", this);
    env.set_context(configuration, status);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sequencer = env.sequencer;
  endfunction

  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    if (configuration.tb_context.clock_vif != null) begin
      configuration.tb_context.clock_vif
        .start(configuration.tb_context.clock_period_ns);
    end
    if (configuration.tb_context.reset_vif != null) begin
      configuration.tb_context.reset_vif
        .initiate(configuration.tb_context.reset_duration_ns, 1);
    end
    phase.drop_objection(this);
  endtask

  protected virtual function void create_configuration();
    CONTEXT tb_context;
    tb_context    = get_tb_context();
    configuration = CONFIGURATION::type_id::create("configuration");
    configuration.set_tb_context(tb_context);
    `tue_randomize_with(configuration, {})
  endfunction

  protected virtual function CONTEXT get_tb_context();
    CONTEXT     tb_context;
    uvm_object  temp;

    if (uvm_config_db #(CONTEXT)::get(null, "", "tb_context", tb_context)) begin
      return tb_context;
    end

    if (uvm_config_db #(uvm_object)::get(null, "", "tb_context", temp) && $cast(tb_context, temp)) begin
      return tb_context;
    end

    return null;
  endfunction

  protected function void set_default_sequence(
    uvm_object_wrapper  default_sequence,
    string              phase,
    uvm_sequencer_base  target_sequencer  = null
  );
    if (target_sequencer == null) begin
      target_sequencer  = sequencer;
    end

    uvm_config_db #(uvm_object_wrapper)::set(target_sequencer, phase, "default_sequence", default_sequence);
  endfunction

  `tue_component_default_constructor(tb_rice_env_test_base)
endclass

class tb_rice_env_test_sequence_base #(
  type  BASE  = uvm_sequence
) extends BASE;
  function new(string name = "tb_rice_env_test_sequence_base");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction
endclass
