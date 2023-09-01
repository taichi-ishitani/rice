class tb_rice_core_basic_beq_bne_blt_bge_test extends tb_rice_core_basic_test_base;
  protected task setup();
    write_inst(32'h0000_0000, inst_addi(1, 0, 1));
    write_inst(32'h0000_0004, inst_addi(2, 0, 12'hFFF));

    //  beq
    write_inst(32'h0000_0008, inst_beq(0, 0, 12'h008));
    write_inst(32'h0000_0010, inst_addi(3, 0, 1));
    write_inst(32'h0000_0014, inst_sw(0, 3, 12'h000));
    write_inst(32'h0000_0018, inst_beq(0, 1, 12'h008));
    write_inst(32'h0000_001C, inst_addi(4, 0, 2));
    write_inst(32'h0000_0020, inst_sw(0, 4, 12'h004));

    //  bne
    write_inst(32'h0000_0024, inst_bne(0, 1, 12'h008));
    write_inst(32'h0000_002C, inst_addi(5, 0, 3));
    write_inst(32'h0000_0030, inst_sw(0, 5, 12'h008));
    write_inst(32'h0000_0034, inst_bne(0, 0, 12'h008));
    write_inst(32'h0000_0038, inst_addi(6, 0, 4));
    write_inst(32'h0000_003C, inst_sw(0, 6, 12'h00C));

    //  blt
    write_inst(32'h0000_0040, inst_blt(2, 0, 12'h008));
    write_inst(32'h0000_0048, inst_addi(7, 0, 5));
    write_inst(32'h0000_004C, inst_sw(0, 7, 12'h010));
    write_inst(32'h0000_0050, inst_blt(0, 2, 12'h008));
    write_inst(32'h0000_0054, inst_addi(8, 0, 6));
    write_inst(32'h0000_0058, inst_sw(0, 8, 12'h014));

    //  bge
    write_inst(32'h0000_005C, inst_bge(0, 2, 12'h008));
    write_inst(32'h0000_0064, inst_addi(9, 0, 7));
    write_inst(32'h0000_0068, inst_sw(0, 9, 12'h018));
    write_inst(32'h0000_006C, inst_bge(2, 0, 12'h008));
    write_inst(32'h0000_0070, inst_addi(10, 0, 8));
    write_inst(32'h0000_0074, inst_sw(0, 10, 12'h01C));

    //  bltu
    write_inst(32'h0000_0078, inst_bltu(0, 2, 12'h008));
    write_inst(32'h0000_0080, inst_addi(11, 0, 9));
    write_inst(32'h0000_0084, inst_sw(0, 11, 12'h020));
    write_inst(32'h0000_0088, inst_bltu(2, 0, 12'h008));
    write_inst(32'h0000_008C, inst_addi(12, 0, 10));
    write_inst(32'h0000_0090, inst_sw(0, 12, 12'h024));

    //  bgeu
    write_inst(32'h0000_0094, inst_bgeu(2, 0, 12'h008));
    write_inst(32'h0000_009C, inst_addi(13, 0, 11));
    write_inst(32'h0000_00A0, inst_sw(0, 13, 12'h028));
    write_inst(32'h0000_00A4, inst_bgeu(0, 2, 12'h008));
    write_inst(32'h0000_00A8, inst_addi(14, 0, 12));
    write_inst(32'h0000_00AC, inst_sw(0, 14, 12'h02C));

    write_inst(32'h0000_00B0, inst_nop());
  endtask

  protected task check_bus_access();
    //  beq
    monito_data_bus_access(32'h0000_0000, 4'hF, 32'h0000_0001);
    monito_data_bus_access(32'h0000_0004, 4'hF, 32'h0000_0002);

    //  bne
    monito_data_bus_access(32'h0000_0008, 4'hF, 32'h0000_0003);
    monito_data_bus_access(32'h0000_000C, 4'hF, 32'h0000_0004);

    //  blt
    monito_data_bus_access(32'h0000_0010, 4'hF, 32'h0000_0005);
    monito_data_bus_access(32'h0000_0014, 4'hF, 32'h0000_0006);

    //  bge
    monito_data_bus_access(32'h0000_0018, 4'hF, 32'h0000_0007);
    monito_data_bus_access(32'h0000_001C, 4'hF, 32'h0000_0008);

    //  bltu
    monito_data_bus_access(32'h0000_0020, 4'hF, 32'h0000_0009);
    monito_data_bus_access(32'h0000_0024, 4'hF, 32'h0000_000A);

    //  bgeu
    monito_data_bus_access(32'h0000_0028, 4'hF, 32'h0000_000B);
    monito_data_bus_access(32'h0000_002C, 4'hF, 32'h0000_000C);
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_beq_bne_blt_bge_test)
  `uvm_component_utils(tb_rice_core_basic_beq_bne_blt_bge_test)
endclass
