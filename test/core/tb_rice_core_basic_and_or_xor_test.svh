class tb_rice_core_basic_and_or_xor_test extends tb_rice_core_basic_test_base;
  protected task setup();
    write_inst(32'h0000_0000, inst_addi(1, 0, 1));

    //  andi
    write_inst(32'h0000_0004, inst_andi(2, 0, 0));
    write_inst(32'h0000_0008, inst_andi(3, 1, 0));
    write_inst(32'h0000_000C, inst_andi(4, 0, 1));
    write_inst(32'h0000_0010, inst_andi(5, 1, 1));
    write_inst(32'h0000_0014, inst_sw(0, 2, 12'h000));
    write_inst(32'h0000_0018, inst_sw(0, 3, 12'h004));
    write_inst(32'h0000_001C, inst_sw(0, 4, 12'h008));
    write_inst(32'h0000_0020, inst_sw(0, 5, 12'h00C));

    //  ori
    write_inst(32'h0000_0024, inst_ori(2, 0, 0));
    write_inst(32'h0000_0028, inst_ori(3, 1, 0));
    write_inst(32'h0000_002C, inst_ori(4, 0, 1));
    write_inst(32'h0000_0030, inst_ori(5, 1, 1));
    write_inst(32'h0000_0034, inst_sw(0, 2, 12'h010));
    write_inst(32'h0000_0038, inst_sw(0, 3, 12'h014));
    write_inst(32'h0000_003C, inst_sw(0, 4, 12'h018));
    write_inst(32'h0000_0040, inst_sw(0, 5, 12'h01C));

    //  xori
    write_inst(32'h0000_0044, inst_xori(2, 0, 0));
    write_inst(32'h0000_0048, inst_xori(3, 1, 0));
    write_inst(32'h0000_004C, inst_xori(4, 0, 1));
    write_inst(32'h0000_0050, inst_xori(5, 1, 1));
    write_inst(32'h0000_0054, inst_sw(0, 2, 12'h020));
    write_inst(32'h0000_0058, inst_sw(0, 3, 12'h024));
    write_inst(32'h0000_005C, inst_sw(0, 4, 12'h028));
    write_inst(32'h0000_0060, inst_sw(0, 5, 12'h02C));

    //  and
    write_inst(32'h0000_0064, inst_and(2, 0, 0));
    write_inst(32'h0000_0068, inst_and(3, 1, 0));
    write_inst(32'h0000_006C, inst_and(4, 0, 1));
    write_inst(32'h0000_0070, inst_and(5, 1, 1));
    write_inst(32'h0000_0074, inst_sw(0, 2, 12'h030));
    write_inst(32'h0000_0078, inst_sw(0, 3, 12'h034));
    write_inst(32'h0000_007C, inst_sw(0, 4, 12'h038));
    write_inst(32'h0000_0080, inst_sw(0, 5, 12'h03C));

    //  or
    write_inst(32'h0000_0084, inst_or(2, 0, 0));
    write_inst(32'h0000_0088, inst_or(3, 1, 0));
    write_inst(32'h0000_008C, inst_or(4, 0, 1));
    write_inst(32'h0000_0090, inst_or(5, 1, 1));
    write_inst(32'h0000_0094, inst_sw(0, 2, 12'h040));
    write_inst(32'h0000_0098, inst_sw(0, 3, 12'h044));
    write_inst(32'h0000_009C, inst_sw(0, 4, 12'h048));
    write_inst(32'h0000_00A0, inst_sw(0, 5, 12'h04C));

    //  xor
    write_inst(32'h0000_00A4, inst_xor(2, 0, 0));
    write_inst(32'h0000_00A8, inst_xor(3, 1, 0));
    write_inst(32'h0000_00AC, inst_xor(4, 0, 1));
    write_inst(32'h0000_00B0, inst_xor(5, 1, 1));
    write_inst(32'h0000_00B4, inst_sw(0, 2, 12'h050));
    write_inst(32'h0000_00B8, inst_sw(0, 3, 12'h054));
    write_inst(32'h0000_00BC, inst_sw(0, 4, 12'h058));
    write_inst(32'h0000_00C0, inst_sw(0, 5, 12'h05C));
  endtask

  protected task check_bus_access();
    //  andi
    monito_data_bus_access(32'h0000_0000, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_0004, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_0008, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_000C, 4'hF, 32'h0000_0001);

    //  ori
    monito_data_bus_access(32'h0000_0010, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_0014, 4'hF, 32'h0000_0001);
    monito_data_bus_access(32'h0000_0018, 4'hF, 32'h0000_0001);
    monito_data_bus_access(32'h0000_001C, 4'hF, 32'h0000_0001);

    //  xori
    monito_data_bus_access(32'h0000_0020, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_0024, 4'hF, 32'h0000_0001);
    monito_data_bus_access(32'h0000_0028, 4'hF, 32'h0000_0001);
    monito_data_bus_access(32'h0000_002C, 4'hF, 32'h0000_0000);

    //  and
    monito_data_bus_access(32'h0000_0030, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_0034, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_0038, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_003C, 4'hF, 32'h0000_0001);

    //  or
    monito_data_bus_access(32'h0000_0040, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_0044, 4'hF, 32'h0000_0001);
    monito_data_bus_access(32'h0000_0048, 4'hF, 32'h0000_0001);
    monito_data_bus_access(32'h0000_004C, 4'hF, 32'h0000_0001);

    //  xor
    monito_data_bus_access(32'h0000_0050, 4'hF, 32'h0000_0000);
    monito_data_bus_access(32'h0000_0054, 4'hF, 32'h0000_0001);
    monito_data_bus_access(32'h0000_0058, 4'hF, 32'h0000_0001);
    monito_data_bus_access(32'h0000_005C, 4'hF, 32'h0000_0000);
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_and_or_xor_test)
  `uvm_component_utils(tb_rice_core_basic_and_or_xor_test)
endclass
