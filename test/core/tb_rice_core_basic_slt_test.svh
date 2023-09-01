class tb_rice_core_basic_slt_test extends tb_rice_core_basic_test_base;
  task setup();
    write_inst(32'h0000_0000, inst_addi(1, 0, 1));
    write_inst(32'h0000_0004, inst_addi(2, 0, 12'hFFF));

    //  slti
    write_inst(32'h0000_0008, inst_slti(3, 0, 0));
    write_inst(32'h0000_000C, inst_slti(4, 0, 1));
    write_inst(32'h0000_0010, inst_slti(5, 1, 0));
    write_inst(32'h0000_0014, inst_slti(6, 0, 12'hFFF));
    write_inst(32'h0000_0018, inst_slti(7, 2, 0));
    write_inst(32'h0000_001C, inst_sw(0, 3, 12'h000));
    write_inst(32'h0000_0020, inst_sw(0, 4, 12'h004));
    write_inst(32'h0000_0024, inst_sw(0, 5, 12'h008));
    write_inst(32'h0000_0028, inst_sw(0, 6, 12'h00C));
    write_inst(32'h0000_002C, inst_sw(0, 7, 12'h010));

    //  sltiu
    write_inst(32'h0000_0030, inst_sltiu(3, 0, 0));
    write_inst(32'h0000_0034, inst_sltiu(4, 0, 1));
    write_inst(32'h0000_0038, inst_sltiu(5, 1, 0));
    write_inst(32'h0000_003C, inst_sltiu(6, 0, 12'hFFF));
    write_inst(32'h0000_0040, inst_sltiu(7, 2, 0));
    write_inst(32'h0000_0044, inst_sw(0, 3, 12'h020));
    write_inst(32'h0000_0048, inst_sw(0, 4, 12'h024));
    write_inst(32'h0000_004C, inst_sw(0, 5, 12'h028));
    write_inst(32'h0000_0050, inst_sw(0, 6, 12'h02C));
    write_inst(32'h0000_0054, inst_sw(0, 7, 12'h030));

    //  slt
    write_inst(32'h0000_0058, inst_slt(3, 0, 0));
    write_inst(32'h0000_005C, inst_slt(4, 0, 1));
    write_inst(32'h0000_0060, inst_slt(5, 1, 0));
    write_inst(32'h0000_0064, inst_slt(6, 0, 2));
    write_inst(32'h0000_0068, inst_slt(7, 2, 0));
    write_inst(32'h0000_006C, inst_sw(0, 3, 12'h040));
    write_inst(32'h0000_0070, inst_sw(0, 4, 12'h044));
    write_inst(32'h0000_0074, inst_sw(0, 5, 12'h048));
    write_inst(32'h0000_0078, inst_sw(0, 6, 12'h04C));
    write_inst(32'h0000_007C, inst_sw(0, 7, 12'h050));

    //  sltu
    write_inst(32'h0000_0080, inst_sltu(3, 0, 0));
    write_inst(32'h0000_0084, inst_sltu(4, 0, 1));
    write_inst(32'h0000_0088, inst_sltu(5, 1, 0));
    write_inst(32'h0000_008C, inst_sltu(6, 0, 2));
    write_inst(32'h0000_0090, inst_sltu(7, 2, 0));
    write_inst(32'h0000_0094, inst_sw(0, 3, 12'h060));
    write_inst(32'h0000_0098, inst_sw(0, 4, 12'h064));
    write_inst(32'h0000_009C, inst_sw(0, 5, 12'h068));
    write_inst(32'h0000_00A0, inst_sw(0, 6, 12'h06C));
    write_inst(32'h0000_00A4, inst_sw(0, 7, 12'h070));

    write_inst(32'h0000_00A8, inst_nop());
  endtask

  protected task check_bus_access();
    //  slti
    monito_data_bus_access(32'h0000_0000, 4'hF, 32'h0000_0000); //   0 < 0
    monito_data_bus_access(32'h0000_0004, 4'hF, 32'h0000_0001); //   0 < 1
    monito_data_bus_access(32'h0000_0008, 4'hF, 32'h0000_0000); //   1 < 0
    monito_data_bus_access(32'h0000_000C, 4'hF, 32'h0000_0000); //   0 < -1
    monito_data_bus_access(32'h0000_0010, 4'hF, 32'h0000_0001); //  -1 < 0

    //  sltiu
    monito_data_bus_access(32'h0000_0020, 4'hF, 32'h0000_0000); //  0x0000_0000 < 0x0000_0000
    monito_data_bus_access(32'h0000_0024, 4'hF, 32'h0000_0001); //  0x0000_0000 < 0x0000_0001
    monito_data_bus_access(32'h0000_0028, 4'hF, 32'h0000_0000); //  0x0000_0001 < 0x0000_0000
    monito_data_bus_access(32'h0000_002C, 4'hF, 32'h0000_0001); //  0x0000_0000 < 0xFFFF_FFFF
    monito_data_bus_access(32'h0000_0030, 4'hF, 32'h0000_0000); //  0xFFFF_FFFF < 0x0000_0000

    //  slt
    monito_data_bus_access(32'h0000_0040, 4'hF, 32'h0000_0000); //   0 < 0
    monito_data_bus_access(32'h0000_0044, 4'hF, 32'h0000_0001); //   0 < 1
    monito_data_bus_access(32'h0000_0048, 4'hF, 32'h0000_0000); //   1 < 0
    monito_data_bus_access(32'h0000_004C, 4'hF, 32'h0000_0000); //   0 < -1
    monito_data_bus_access(32'h0000_0050, 4'hF, 32'h0000_0001); //  -1 < 0

    //  sltu
    monito_data_bus_access(32'h0000_0060, 4'hF, 32'h0000_0000); //  0x0000_0000 < 0x0000_0000
    monito_data_bus_access(32'h0000_0064, 4'hF, 32'h0000_0001); //  0x0000_0000 < 0x0000_0001
    monito_data_bus_access(32'h0000_0068, 4'hF, 32'h0000_0000); //  0x0000_0001 < 0x0000_0000
    monito_data_bus_access(32'h0000_006C, 4'hF, 32'h0000_0001); //  0x0000_0000 < 0xFFFF_FFFF
    monito_data_bus_access(32'h0000_0070, 4'hF, 32'h0000_0000); //  0xFFFF_FFFF < 0x0000_0000
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_slt_test)
  `uvm_component_utils(tb_rice_core_basic_slt_test)
endclass
