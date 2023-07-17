typedef tue_reactive_sequencer #(
  .CONFIGURATION  (tb_rice_bus_configuration  ),
  .STATUS         (tb_rice_bus_status         ),
  .ITEM           (tb_rice_bus_slave_item     ),
  .REQUEST        (tb_rice_bus_slave_item     ),
  .REQUEST_HANDLE (tb_rice_bus_item           )
) tb_rice_bus_slave_sequencer_base;

class tb_rice_bus_slave_sequencer extends tb_rice_bus_sequencer_base #(
  .BASE (tb_rice_bus_slave_sequencer_base )
);
  protected tb_rice_bus_item_waiter request_waiter;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    request_waiter  = new("request_waiter", this);
    request_waiter.set_context(configuration, status);
  endfunction

  function void write_request(tb_rice_bus_item request);
    request_waiter.write(request);
  endfunction

  task get_request(ref tb_rice_bus_slave_item request);
    tb_rice_bus_item  temp;
    request_waiter.get_item(temp);
    $cast(request, temp);
  endtask

  `tue_component_default_constructor(tb_rice_bus_slave_sequencer)
  `uvm_component_utils(tb_rice_bus_slave_sequencer)
endclass
