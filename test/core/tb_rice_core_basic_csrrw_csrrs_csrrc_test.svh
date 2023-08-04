class tb_rice_core_basic_csrrw_csrrs_csrrc_test extends tb_rice_core_basic_test_base;
  protected task setup();
    write_inst(32'h0000_0000, inst_addi(1, 0, 12'hFFF));

    //  csrrwi/csrrci/csrrsi
    write_inst(32'h0000_0004, inst_csrrwi(0, 12'h340, 5'b10101));
    write_inst(32'h0000_0008, inst_csrrsi(2, 12'h340, 5'b01010));
    write_inst(32'h0000_000C, inst_csrrci(3, 12'h340, 5'b11111));
    write_inst(32'h0000_0010, inst_csrrwi(4, 12'h340, 5'b00000));
    write_inst(32'h0000_0014, inst_sw(0, 2, 12'h000));
    write_inst(32'h0000_0018, inst_sw(0, 3, 12'h004));
    write_inst(32'h0000_001C, inst_sw(0, 4, 12'h008));

    //  csrrw/csrrc/csrs
    write_inst(32'h0000_0020, inst_csrrw(0, 12'h340, 1));
    write_inst(32'h0000_0024, inst_csrrc(2, 12'h340, 1));
    write_inst(32'h0000_0028, inst_csrrs(3, 12'h340, 1));
    write_inst(32'h0000_002C, inst_csrrw(4, 12'h340, 0));
    write_inst(32'h0000_0030, inst_sw(0, 2, 12'h010));
    write_inst(32'h0000_0034, inst_sw(0, 3, 12'h014));
    write_inst(32'h0000_0038, inst_sw(0, 4, 12'h018));
  endtask

  protected task check_bus_access();
    monito_data_bus_access(32'h0000_0000, 4'hF, 32'h0000_0015);
    monito_data_bus_access(32'h0000_0004, 4'hF, 32'h0000_001F);
    monito_data_bus_access(32'h0000_0008, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_0010, 4'hF, 32'hFFFF_FFFF);
    monito_data_bus_access(32'h0000_0014, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_0018, 4'hF, 32'hFFFF_FFFF);
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_csrrw_csrrs_csrrc_test)
  `uvm_component_utils(tb_rice_core_basic_csrrw_csrrs_csrrc_test)
endclass
