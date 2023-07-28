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

class tb_rice_core_basic_test_base extends tb_rice_core_test_base;
  const tb_rice_bus_address START_ADDRESS   = 'h8000_0000;

  task pre_reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    setup();
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    check_bus_access();
    configuration.tb_context.clock_vif.wait_cycles(1);
    phase.drop_objection(this);
  endtask

  protected virtual task setup();
  endtask

  protected virtual task check_bus_access();
  endtask

  protected task write_inst(
    tb_rice_bus_address offset,
    bit [31:0]          inst
  );
    tb_rice_bus_address address;
    tb_rice_bus_status  bus_status;
    address     = START_ADDRESS + offset;
    bus_status  = sequencer.inst_bus_sequencer.get_status();
    bus_status.memory.put(inst, 4'hF, 4, address, 0);
  endtask

  protected task write_data(
    tb_rice_bus_address address,
    bit [31:0]          data
  );
    tb_rice_bus_status  bus_status;
    bus_status  = sequencer.data_bus_sequencer.get_status();
    bus_status.memory.put(data, 4'hF, 4, address, 0);
  endtask

  protected task monito_data_bus_access(
    tb_rice_bus_address address,
    tb_rice_bus_strobe  strobe,
    tb_rice_bus_data    data
  );
    tb_rice_bus_item  bus_item;
    while (1) begin
      sequencer.data_bus_sequencer.get_item(bus_item);
      if ((bus_item.address == address) && (bus_item.strobe == strobe) && (bus_item.data == data)) begin
        return;
      end
    end
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_test_base)
endclass
