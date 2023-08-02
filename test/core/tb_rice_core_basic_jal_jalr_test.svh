class tb_rice_core_basic_jal_jalr_test extends tb_rice_core_basic_test_base;
  protected task setup();
    write_inst(32'h0000_0000, inst_auipc(1, 0));

    //  jal
    write_inst(32'h0000_0004, inst_jal(2, 20'h1000));
    write_inst(32'h0000_1004, inst_sw(0, 2, 12'h000));

    //  jalr
    write_inst(32'h0000_1008, inst_jalr(3, 1, 12'h100));
    write_inst(32'h0000_0100, inst_sw(0, 3, 12'h004));
  endtask

  protected task check_bus_access();
    //  jal
    monito_data_bus_access(32'h0000_0000, 4'hF, START_ADDRESS + 32'h0000_0004 + 32'h0000_0004);

    //  jalr
    monito_data_bus_access(32'h0000_0004, 4'hF, START_ADDRESS + 32'h0000_1008 + 32'h0000_0004);
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_jal_jalr_test)
  `uvm_component_utils(tb_rice_core_basic_jal_jalr_test)
endclass
