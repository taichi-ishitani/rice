class tb_rice_core_basic_add_sub_test extends tb_rice_core_basic_test_base;
  protected task setup();
    //  addi
    write_inst(32'h0000_0000, inst_addi(1, 0, 1));
    write_inst(32'h0000_0004, inst_addi(2, 0, 2));
    write_inst(32'h0000_0008, inst_addi(3, 0, 3));
    write_inst(32'h0000_000C, inst_addi(4, 0, 4));
    write_inst(32'h0000_0010, inst_sw(0, 1, 12'h000));
    write_inst(32'h0000_0014, inst_sw(0, 2, 12'h004));
    write_inst(32'h0000_0018, inst_sw(0, 3, 12'h008));
    write_inst(32'h0000_001C, inst_sw(0, 4, 12'h00C));

    //  add/sub
    write_inst(32'h0000_0020, inst_add(5, 2, 1));
    write_inst(32'h0000_0024, inst_sub(6, 4, 3));
    write_inst(32'h0000_0028, inst_sw(0, 5, 12'h010));
    write_inst(32'h0000_002C, inst_sw(0, 6, 12'h014));

    //  addi/add/sub forwarding
    write_inst(32'h0000_0030, inst_addi(1, 0, 1));
    write_inst(32'h0000_0034, inst_addi(2, 1, 2));
    write_inst(32'h0000_0038, inst_add(3, 1, 2));
    write_inst(32'h0000_003C, inst_sub(4, 2, 3));
    write_inst(32'h0000_0040, inst_sw(0, 1, 12'h020));
    write_inst(32'h0000_0044, inst_sw(0, 2, 12'h024));
    write_inst(32'h0000_0048, inst_sw(0, 3, 12'h028));
    write_inst(32'h0000_004C, inst_sw(0, 4, 12'h02C));
  endtask

  protected task check_bus_access();
    monito_data_bus_access(32'h0000_0000, 4'hF, 32'h0000_0001); //  x1 <- 0(x0) + 1
    monito_data_bus_access(32'h0000_0004, 4'hF, 32'h0000_0002); //  x2 <- 0(x0) + 2
    monito_data_bus_access(32'h0000_0008, 4'hF, 32'h0000_0003); //  x3 <- 0(x0) + 3
    monito_data_bus_access(32'h0000_000C, 4'hF, 32'h0000_0004); //  x4 <- 0(x0) + 4
    monito_data_bus_access(32'h0000_0010, 4'hF, 32'h0000_0003); //  x5 <- 2(x2) + 1(x1)
    monito_data_bus_access(32'h0000_0014, 4'hF, 32'h0000_0001); //  x6 <- 4(x4) - 3(x3)
    monito_data_bus_access(32'h0000_0020, 4'hF, 32'h0000_0001); //  x1 <- 0(x0) + 1
    monito_data_bus_access(32'h0000_0024, 4'hF, 32'h0000_0003); //  x2 <- 1(x1) + 2
    monito_data_bus_access(32'h0000_0028, 4'hF, 32'h0000_0004); //  x3 <- 1(x1) + 3(x2)
    monito_data_bus_access(32'h0000_002C, 4'hF, 32'hFFFF_FFFF); //  x4 <- 3(x2) - 4(x3)
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_add_sub_test)
  `uvm_component_utils(tb_rice_core_basic_add_sub_test)
endclass
