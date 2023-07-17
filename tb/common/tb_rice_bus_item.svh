class tb_rice_bus_item extends tue_sequence_item #(
  .CONFIGURATION  (tb_rice_bus_configuration  ),
  .STATUS         (tb_rice_bus_status         )
);
  rand  tb_rice_bus_address address;
  rand  tb_rice_bus_strobe  strobe;
  rand  tb_rice_bus_data    data;
        uvm_event           request_begin_event;
        time                request_begin_time;
        uvm_event           request_end_event;
        time                request_end_time;
        uvm_event           response_begin_event;
        time                response_begin_time;
        uvm_event           response_end_event;
        time                response_end_time;

  function new(string name = "tb_rice_bus_item");
    super.new(name);
    request_begin_event   = get_event("request_begin");
    request_begin_time    = -1;
    request_end_event     = get_event("request_end");
    request_end_time      = -1;
    response_begin_event  = get_event("response_begin");
    response_begin_time   = -1;
    response_end_event    = get_event("response_end");
    response_end_time     = -1;
  endfunction

  function bit is_write();
    return strobe != 0;
  endfunction

  function bit is_read();
    return strobe == 0;
  endfunction

  `define tb_rice_declare_begin_end_event_api(EVENT_TYPE) \
  function void begin_``EVENT_TYPE``(time begin_time = 0); \
    EVENT_TYPE``_begin_time = (begin_time <= 0) ? $time : begin_time; \
    EVENT_TYPE``_begin_event.trigger(); \
  endfunction \
  function void end_``EVENT_TYPE``(time end_time = 0); \
    EVENT_TYPE``_end_time = (end_time <= 0) ? $time : end_time; \
    EVENT_TYPE``_end_event.trigger(); \
  endfunction \
  function bit EVENT_TYPE``_began(); \
    return EVENT_TYPE``_begin_event.is_on(); \
  endfunction \
  function bit EVENT_TYPE``_ended(); \
    return EVENT_TYPE``_end_event.is_on(); \
  endfunction

  `tb_rice_declare_begin_end_event_api(request)
  `tb_rice_declare_begin_end_event_api(response)

  `undef tb_rice_declare_begin_end_event_api

  `uvm_object_utils_begin(tb_rice_bus_item)
    `uvm_field_int(address, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(strobe, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(data, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass

class tb_rice_bus_slave_item extends tb_rice_bus_item;
  constraint c_valid_data {
    (data >> this.configuration.data_width) == 0;
  }

  function void pre_randomize();
    super.pre_randomize();
    address.rand_mode(0);
    strobe.rand_mode(0);
    if (is_write()) begin
      data.rand_mode(0);
    end
  endfunction

  `tue_object_default_constructor(tb_rice_bus_slave_item)
  `uvm_object_utils(tb_rice_bus_slave_item)
endclass
