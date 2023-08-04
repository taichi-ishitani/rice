class tb_rice_core_basic_exception_test extends tb_rice_core_basic_test_base;
  protected task setup();
    write_inst(32'h0000_0000, inst_auipc(1, 0));

    //  illegal instruction
    write_inst(32'h0000_0004, inst_addi(2, 1, 12'h100));
    write_inst(32'h0000_0008, inst_addi(3, 1, 12'h200));
    write_inst(32'h0000_000C, inst_csrrw(0, 12'h305, 2));
    write_inst(32'h0000_0010, inst_csrrw(0, 12'hF11, 0));

    write_inst(32'h0000_0100, inst_csrrs(4, 12'h341, 0));
    write_inst(32'h0000_0104, inst_csrrs(5, 12'h342, 0));
    write_inst(32'h0000_0108, inst_csrrw(0, 12'h341, 3));
    write_inst(32'h0000_010C, inst_mret());

    write_inst(32'h0000_0200, inst_sw(0, 4, 12'h000));
    write_inst(32'h0000_0204, inst_sw(0, 5, 12'h004));

    //  ecall
    write_inst(32'h0000_0208, inst_addi(2, 1, 12'h300));
    write_inst(32'h0000_020C, inst_addi(3, 1, 12'h400));
    write_inst(32'h0000_0210, inst_csrrw(0, 12'h305, 2));
    write_inst(32'h0000_0214, inst_ecall());

    write_inst(32'h0000_0300, inst_csrrs(4, 12'h341, 0));
    write_inst(32'h0000_0304, inst_csrrs(5, 12'h342, 0));
    write_inst(32'h0000_0308, inst_csrrw(0, 12'h341, 3));
    write_inst(32'h0000_030C, inst_mret());

    write_inst(32'h0000_0400, inst_sw(0, 4, 12'h010));
    write_inst(32'h0000_0404, inst_sw(0, 5, 12'h014));

    //  ebreak
    write_inst(32'h0000_0408, inst_addi(2, 1, 12'h500));
    write_inst(32'h0000_040C, inst_addi(3, 1, 12'h600));
    write_inst(32'h0000_0410, inst_csrrw(0, 12'h305, 2));
    write_inst(32'h0000_0414, inst_ebreak());

    write_inst(32'h0000_0500, inst_csrrs(4, 12'h341, 0));
    write_inst(32'h0000_0504, inst_csrrs(5, 12'h342, 0));
    write_inst(32'h0000_0508, inst_csrrw(0, 12'h341, 3));
    write_inst(32'h0000_050C, inst_mret());

    write_inst(32'h0000_0600, inst_sw(0, 4, 12'h020));
    write_inst(32'h0000_0604, inst_sw(0, 5, 12'h024));
  endtask

  protected task check_bus_access();
    monito_data_bus_access(32'h0000_0000, 4'hF, 32'h8000_0010);
    monito_data_bus_access(32'h0000_0004, 4'hF, 32'h0000_0002);

    monito_data_bus_access(32'h0000_0010, 4'hF, 32'h8000_0214);
    monito_data_bus_access(32'h0000_0014, 4'hF, 32'h0000_000B);

    monito_data_bus_access(32'h0000_0020, 4'hF, 32'h8000_0414);
    monito_data_bus_access(32'h0000_0024, 4'hF, 32'h0000_0003);
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_exception_test)
  `uvm_component_utils(tb_rice_core_basic_exception_test)
endclass
