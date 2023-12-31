class tb_rice_core_basic_lw_sw_test extends tb_rice_core_basic_test_base;
  protected task setup();
    write_inst(32'h0000_0000, inst_lw(6, 0, 12'h008));
    write_inst(32'h0000_0004, inst_sw(0, 6, 12'h010));
    write_inst(32'h0000_0008, inst_nop());
    write_data(32'h0000_0008, 32'h2222_2222);
  endtask

  protected task check_bus_access();
    monito_data_bus_access(32'h0000_0010, 4'hF, 32'h2222_2222);
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_lw_sw_test)
  `uvm_component_utils(tb_rice_core_basic_lw_sw_test)
endclass
