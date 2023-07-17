class tb_rice_bus_monitor_base #(
  type  BASE  = uvm_component,
  type  ITEM  = tb_rice_bus_item
) extends tb_rice_bus_component_base #(BASE);
  protected tb_rice_bus_item  item_queue[$];

  task run_phase(uvm_phase phase);
    while (1) begin
      do_reset();
      fork
        request_monitor();
        response_monitor();
        @(negedge vif.i_rst_n);
      join_any
      disable fork;
    end
  endtask

  protected virtual task do_reset();
    foreach (item_queue[i]) begin
      if (!item_queue[i].finished()) begin
        end_tr(item_queue[i]);
      end
    end
    item_queue.delete();

    @(posedge vif.i_rst_n);
  endtask

  protected virtual task request_monitor();
    tb_rice_bus_item  item;

    forever begin
      do begin
        @(vif.monitor_cb);
      end while (!vif.monitor_cb.request_valid);

      item  = create_monitor_item("monitor_item");
      sample_request(item);
      begin_request(item);

      while (!vif.monitor_cb.request_ready) begin
        @(vif.monitor_cb);
      end
      end_request(item);
    end
  endtask

  protected virtual function tb_rice_bus_item create_monitor_item(string name);
    ITEM  item;
    item  = ITEM::type_id::create(name);
    item.set_context(configuration, status);
    return item;
  endfunction

  protected virtual function void sample_request(tb_rice_bus_item item);
    item.address  = vif.monitor_cb.address;
    item.strobe   = vif.monitor_cb.strobe;
    if (item.is_write()) begin
      item.data = vif.monitor_cb.write_data;
    end
  endfunction

  protected virtual function void begin_request(tb_rice_bus_item item);
    super.begin_request(item);
    if (item.is_read()) begin
      item_queue.push_back(item);
    end
  endfunction

  protected virtual function void end_request(tb_rice_bus_item item);
    super.end_request(item);
    if (item.is_write()) begin
      item_port.write(item);
    end
  endfunction

  protected virtual task response_monitor();
    tb_rice_bus_item  item;

    forever begin
      do begin
        @(vif.monitor_cb);
      end while (!vif.monitor_cb.response_valid);

      item  = item_queue.pop_front();
      sample_response(item);
      begin_response(item);

      while (!vif.monitor_cb.response_ready) begin
        @(vif.monitor_cb);
      end
      end_response(item);
    end
  endtask

  protected virtual function void sample_response(tb_rice_bus_item item);
    if (item.is_read()) begin
      item.data = vif.monitor_cb.read_data;
    end
  endfunction

  protected virtual function void end_response(tb_rice_bus_item item);
    super.end_response(item);
    item_port.write(item);
  endfunction

  `tue_component_default_constructor(tb_rice_bus_monitor_base)
endclass
