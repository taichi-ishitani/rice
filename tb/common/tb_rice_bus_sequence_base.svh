class tb_rice_bus_sequence_base #(
  type  BASE      = uvm_sequence,
  type  ITEM      = uvm_sequence_item,
  type  SEQUENCER = uvm_sequencer
) extends BASE;
  `uvm_declare_p_sequencer(SEQUENCER)

  function new(string name = "tb_rice_bus_sequence_base");
    super.new(name);
    set_automatic_phase_objection(0);
  endfunction

  virtual task get_item(ref ITEM item);
    tb_rice_bus_item  temp;
    p_sequencer.get_item(temp);
    $cast(item, temp);
  endtask
endclass
