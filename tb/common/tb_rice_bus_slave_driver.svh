typedef tue_driver #(
  .CONFIGURATION  (tb_rice_bus_configuration  ),
  .STATUS         (tb_rice_bus_status         ),
  .REQ            (tb_rice_bus_slave_item     )
) tb_rice_bus_slave_driver_base;

class tb_rice_bus_slave_driver extends tb_rice_bus_component_base #(
  .BASE (tb_rice_bus_slave_driver_base  )
);
  protected tb_rice_bus_item  currnet_item;

  task run_phase(uvm_phase phase);
    while (1) begin
      do_reset();
      fork
        response_driver();
        @(negedge vif.i_rst_n);
      join_any
      disable fork;
    end
  endtask

  protected virtual task do_reset();
    if (currnet_item != null) begin
      end_tr(currnet_item);
      currnet_item  = null;
    end

    vif.request_ready   <= '1;
    vif.response_valid  <= '0;

    @(posedge vif.i_rst_n);
  endtask

  protected virtual task response_driver();
    forever begin
      wait_for_next_item();
      drive_response_item();
      finish_response_item();
    end
  endtask

  protected virtual task wait_for_next_item();
    seq_item_port.get_next_item(currnet_item);
    begin_response(currnet_item);
    if (!vif.at_slave_cb_edge.triggered) begin
      @(vif.slave_cb);
    end
  endtask

  protected virtual task drive_response_item();
    vif.response_valid  <= '1;
    vif.read_data       <= currnet_item.data;

    do begin
      @(vif.slave_cb);
    end while (!vif.slave_cb.response_ready);

    vif.response_valid  <= '0;
  endtask

  protected virtual function void finish_response_item();
    end_response(currnet_item);
    seq_item_port.item_done();
    currnet_item  = null;
  endfunction

  `tue_component_default_constructor(tb_rice_bus_slave_driver)
  `uvm_component_utils(tb_rice_bus_slave_driver)
endclass
