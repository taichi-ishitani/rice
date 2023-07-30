class tb_rice_core_basic_sll_srl_sra_test extends tb_rice_core_basic_test_base;
  task setup();
    write_inst(32'h0000_0000, inst_addi(1, 0, 1));
    write_inst(32'h0000_0004, inst_lui(2, 32'h8000_0000));
    write_inst(32'h0000_0008, inst_addi(3, 0, 31));

    //  slli
    write_inst(32'h0000_000C, inst_slli(4, 1, 0));
    write_inst(32'h0000_0010, inst_slli(5, 1, 1));
    write_inst(32'h0000_0014, inst_slli(6, 1, 31));
    write_inst(32'h0000_0018, inst_sw(0, 4, 12'h000));
    write_inst(32'h0000_001C, inst_sw(0, 5, 12'h004));
    write_inst(32'h0000_0020, inst_sw(0, 6, 12'h008));

    //  srli
    write_inst(32'h0000_0024, inst_srli(4, 2, 0));
    write_inst(32'h0000_0028, inst_srli(5, 2, 1));
    write_inst(32'h0000_002C, inst_srli(6, 2, 31));
    write_inst(32'h0000_0030, inst_sw(0, 4, 12'h010));
    write_inst(32'h0000_0034, inst_sw(0, 5, 12'h014));
    write_inst(32'h0000_0038, inst_sw(0, 6, 12'h018));

    //  srli
    write_inst(32'h0000_003C, inst_srai(4, 2, 0));
    write_inst(32'h0000_0040, inst_srai(5, 2, 1));
    write_inst(32'h0000_0044, inst_srai(6, 2, 31));
    write_inst(32'h0000_0048, inst_sw(0, 4, 12'h020));
    write_inst(32'h0000_004C, inst_sw(0, 5, 12'h024));
    write_inst(32'h0000_0050, inst_sw(0, 6, 12'h028));

    //  sll
    write_inst(32'h0000_0054, inst_sll(4, 1, 0));
    write_inst(32'h0000_0058, inst_sll(5, 1, 1));
    write_inst(32'h0000_005C, inst_sll(6, 1, 3));
    write_inst(32'h0000_0060, inst_sw(0, 4, 12'h030));
    write_inst(32'h0000_0064, inst_sw(0, 5, 12'h034));
    write_inst(32'h0000_0068, inst_sw(0, 6, 12'h038));

    //  srl
    write_inst(32'h0000_006C, inst_srl(4, 2, 0));
    write_inst(32'h0000_0070, inst_srl(5, 2, 1));
    write_inst(32'h0000_0074, inst_srl(6, 2, 3));
    write_inst(32'h0000_0078, inst_sw(0, 4, 12'h040));
    write_inst(32'h0000_007C, inst_sw(0, 5, 12'h044));
    write_inst(32'h0000_0080, inst_sw(0, 6, 12'h048));

    //  sra
    write_inst(32'h0000_0084, inst_sra(4, 2, 0));
    write_inst(32'h0000_0088, inst_sra(5, 2, 1));
    write_inst(32'h0000_008C, inst_sra(6, 2, 3));
    write_inst(32'h0000_0090, inst_sw(0, 4, 12'h050));
    write_inst(32'h0000_0094, inst_sw(0, 5, 12'h054));
    write_inst(32'h0000_0098, inst_sw(0, 6, 12'h058));
  endtask

  protected task check_bus_access();
    //  slli
    monito_data_bus_access(32'h0000_0000, 4'hF, 32'h0000_0001); //  32'h0000_0001 << 0
    monito_data_bus_access(32'h0000_0004, 4'hF, 32'h0000_0002); //  32'h0000_0001 << 1
    monito_data_bus_access(32'h0000_0008, 4'hF, 32'h8000_0000); //  32'h0000_0001 << 31

    //  srli
    monito_data_bus_access(32'h0000_0010, 4'hF, 32'h8000_0000); //  32'h8000_0000 >> 0
    monito_data_bus_access(32'h0000_0014, 4'hF, 32'h4000_0000); //  32'h8000_0000 >> 1
    monito_data_bus_access(32'h0000_0018, 4'hF, 32'h0000_0001); //  32'h8000_0000 >> 31

    //  srai
    monito_data_bus_access(32'h0000_0020, 4'hF, 32'h8000_0000); //  32'h8000_0000 >>> 0
    monito_data_bus_access(32'h0000_0024, 4'hF, 32'hC000_0000); //  32'h8000_0000 >>> 1
    monito_data_bus_access(32'h0000_0028, 4'hF, 32'hFFFF_FFFF); //  32'h8000_0000 >>> 31

    //  sll
    monito_data_bus_access(32'h0000_0030, 4'hF, 32'h0000_0001); //  32'h0000_0001 << 0
    monito_data_bus_access(32'h0000_0034, 4'hF, 32'h0000_0002); //  32'h0000_0001 << 1
    monito_data_bus_access(32'h0000_0038, 4'hF, 32'h8000_0000); //  32'h0000_0001 << 31

    //  srl
    monito_data_bus_access(32'h0000_0040, 4'hF, 32'h8000_0000); //  32'h8000_0000 >> 0
    monito_data_bus_access(32'h0000_0044, 4'hF, 32'h4000_0000); //  32'h8000_0000 >> 1
    monito_data_bus_access(32'h0000_0048, 4'hF, 32'h0000_0001); //  32'h8000_0000 >> 31

    //  sra
    monito_data_bus_access(32'h0000_0050, 4'hF, 32'h8000_0000); //  32'h8000_0000 >>> 0
    monito_data_bus_access(32'h0000_0054, 4'hF, 32'hC000_0000); //  32'h8000_0000 >>> 1
    monito_data_bus_access(32'h0000_0058, 4'hF, 32'hFFFF_FFFF); //  32'h8000_0000 >>> 31
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_sll_srl_sra_test)
  `uvm_component_utils(tb_rice_core_basic_sll_srl_sra_test)
endclass
