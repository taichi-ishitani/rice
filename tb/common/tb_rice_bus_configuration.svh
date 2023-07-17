class tb_rice_bus_configuration extends tue_configuration;
        tb_rice_bus_vif vif;
  rand  int             address_width;
  rand  int             strobe_width;
  rand  int             data_width;

  constraint c_valid_width {
    address_width inside {32, 64};
    strobe_width == (data_width / 8);
    data_width inside {32, 64};
  }

  `tue_object_default_constructor(tb_rice_bus_configuration)
  `uvm_object_utils_begin(tb_rice_bus_configuration)
    `uvm_field_int(address_width, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(data_width, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
endclass
