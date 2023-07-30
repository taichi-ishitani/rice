class tb_rice_core_basic_lui_auipc_test extends tb_rice_core_basic_test_base;
  protected task setup();
    //  lui
    write_inst(32'h0000_0000, inst_lui(1, 32'h0000_0000));
    write_inst(32'h0000_0004, inst_lui(2, 32'h0000_1000));
    write_inst(32'h0000_0008, inst_lui(3, 32'hFFFF_F000));
    write_inst(32'h0000_000C, inst_sw(0, 1, 12'h000));
    write_inst(32'h0000_0010, inst_sw(0, 2, 12'h004));
    write_inst(32'h0000_0014, inst_sw(0, 3, 12'h008));

    //  auipc
    write_inst(32'h0000_0018, inst_auipc(1, 32'h0000_0000));
    write_inst(32'h0000_001C, inst_auipc(2, 32'h0000_1000));
    write_inst(32'h0000_0020, inst_auipc(3, 32'hFFFF_F000));
    write_inst(32'h0000_0024, inst_sw(0, 1, 12'h010));
    write_inst(32'h0000_0028, inst_sw(0, 2, 12'h014));
    write_inst(32'h0000_002C, inst_sw(0, 3, 12'h018));
  endtask

  protected task check_bus_access();
    //  lui
    monito_data_bus_access(32'h0000_0000, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_0004, 4'hF, 32'h0000_1000);
    monito_data_bus_access(32'h0000_0008, 4'hF, 32'hFFFF_F000);

    //  auipc
    monito_data_bus_access(32'h0000_0010, 4'hF, 32'h8000_0018); //  pc('h8000_0018) + 'h0000_0000
    monito_data_bus_access(32'h0000_0014, 4'hF, 32'h8000_101C); //  pc('h8000_001C) + 'h0000_1000
    monito_data_bus_access(32'h0000_0018, 4'hF, 32'h7FFF_F020); //  pc('h8000_0020) + 'hFFFF_F000
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_lui_auipc_test)
  `uvm_component_utils(tb_rice_core_basic_lui_auipc_test)
endclass
