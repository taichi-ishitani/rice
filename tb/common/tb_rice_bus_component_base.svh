class tb_rice_bus_component_base #(
  type  BASE  = uvm_component
) extends BASE;
  protected tb_rice_bus_vif vif;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    vif = configuration.vif;
  endfunction

  protected virtual function void begin_request(tb_rice_bus_item item);
    void'(begin_tr(item));
    item.begin_request();
  endfunction

  protected virtual function void end_request(tb_rice_bus_item item);
    item.end_request();
    if (item.is_write()) begin
      end_tr(item);
    end
  endfunction

  protected virtual function void begin_response(tb_rice_bus_item item);
    item.begin_response();
  endfunction

  protected virtual function void end_response(tb_rice_bus_item item);
    item.end_response();
    end_tr(item);
  endfunction

  `tue_component_default_constructor(tb_rice_bus_component_base)
endclass
