class tb_rice_bus_sequencer_base #(
  type  BASE  = uvm_component
) extends BASE;
  uvm_analysis_export #(tb_rice_bus_item) item_export;

  protected tb_rice_bus_item_waiter item_waiter;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_export = new("item_export", this);
    item_waiter = new("item_waiter", this);
    item_waiter.set_context(configuration, status);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    item_export.connect(item_waiter.analysis_export);
  endfunction

  virtual task get_item(ref tb_rice_bus_item item);
    item_waiter.get_item(item);
  endtask

  `tue_component_default_constructor(tb_rice_bus_sequencer_base)
endclass
