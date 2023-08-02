class tb_rice_core_basic_test_base extends tb_rice_core_test_base;
  const tb_rice_bus_address START_ADDRESS   = 'h8000_0000;

  task pre_reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    setup();
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    check_bus_access();
    configuration.tb_context.clock_vif.wait_cycles(1);
    phase.drop_objection(this);
  endtask

  protected virtual task setup();
  endtask

  protected virtual task check_bus_access();
  endtask

  protected function bit [31:0] inst_lw(
    int         rd,
    int         rs,
    bit [11:0]  offset
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0000011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b010;
    inst[19:15] = rs;
    inst[31:20] = offset;
    return inst;
  endfunction

  protected function bit [31:0] inst_sw(
    int         rs1,
    int         rs2,
    bit [11:0]  offset
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0100011;
    inst[11:7]  = offset[4:0];
    inst[14:12] = 3'b010;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = offset[11:5];
    return inst;
  endfunction

  protected function bit [31:0] inst_lui(
    int         rd,
    bit [31:0]  imm
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0110111;
    inst[11:7]  = rd;
    inst[31:12] = imm[31:12];
    return inst;
  endfunction

  protected function bit [31:0] inst_auipc(
    int         rd,
    bit [31:0]  imm
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0010111;
    inst[11:7]  = rd;
    inst[31:12] = imm[31:12];
    return inst;
  endfunction

  protected function bit [31:0] inst_addi(
    int         rd,
    int         rs,
    bit [11:0]  imm
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0010011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b000;
    inst[19:15] = rs;
    inst[31:20] = imm;
    return inst;
  endfunction

  protected function bit [31:0] inst_add(
    int rd,
    int rs1,
    int rs2
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0110011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b000;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = 7'b0000000;
    return inst;
  endfunction

  protected function bit [31:0] inst_sub(
    int rd,
    int rs1,
    int rs2
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0110011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b000;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = 7'b0100000;
    return inst;
  endfunction

  protected function bit [31:0] inst_andi(
    int         rd,
    int         rs,
    bit [11:0]  imm
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0010011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b111;
    inst[19:15] = rs;
    inst[31:20] = imm;
    return inst;
  endfunction

  protected function bit [31:0] inst_ori(
    int         rd,
    int         rs,
    bit [11:0]  imm
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0010011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b110;
    inst[19:15] = rs;
    inst[31:20] = imm;
    return inst;
  endfunction

  protected function bit [31:0] inst_xori(
    int         rd,
    int         rs,
    bit [11:0]  imm
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0010011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b100;
    inst[19:15] = rs;
    inst[31:20] = imm;
    return inst;
  endfunction

  protected function bit [31:0] inst_and(
    int rd,
    int rs1,
    int rs2
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0110011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b111;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = 7'b0000000;
    return inst;
  endfunction

  protected function bit [31:0] inst_or(
    int rd,
    int rs1,
    int rs2
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0110011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b110;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = 7'b0000000;
    return inst;
  endfunction

  protected function bit [31:0] inst_xor(
    int rd,
    int rs1,
    int rs2
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0110011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b100;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = 7'b0000000;
    return inst;
  endfunction

  protected function bit [31:0] inst_slli(
    int rd,
    int rs,
    int shamt
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0010011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b001;
    inst[19:15] = rs;
    inst[24:20] = shamt;
    inst[31:25] = 7'b0000000;
    return inst;
  endfunction

  protected function bit [31:0] inst_srli(
    int rd,
    int rs,
    int shamt
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0010011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b101;
    inst[19:15] = rs;
    inst[24:20] = shamt;
    inst[31:25] = 7'b0000000;
    return inst;
  endfunction

  protected function bit [31:0] inst_srai(
    int rd,
    int rs,
    int shamt
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0010011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b101;
    inst[19:15] = rs;
    inst[24:20] = shamt;
    inst[31:25] = 7'b0100000;
    return inst;
  endfunction

  protected function bit [31:0] inst_sll(
    int rd,
    int rs1,
    int rs2
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0110011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b001;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = 7'b0000000;
    return inst;
  endfunction

  protected function bit [31:0] inst_srl(
    int rd,
    int rs1,
    int rs2
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0110011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b101;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = 7'b0000000;
    return inst;
  endfunction

  protected function bit [31:0] inst_sra(
    int rd,
    int rs1,
    int rs2
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0110011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b101;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = 7'b0100000;
    return inst;
  endfunction

  protected function bit [31:0] inst_slti(
    int         rd,
    int         rs,
    bit [11:0]  imm
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0010011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b010;
    inst[19:15] = rs;
    inst[31:20] = imm;
    return inst;
  endfunction

  protected function bit [31:0] inst_sltiu(
    int         rd,
    int         rs,
    bit [11:0]  imm
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0010011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b011;
    inst[19:15] = rs;
    inst[31:20] = imm;
    return inst;
  endfunction

  protected function bit [31:0] inst_slt(
    int rd,
    int rs1,
    int rs2
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0110011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b010;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = 7'b0000000;
    return inst;
  endfunction

  protected function bit [31:0] inst_sltu(
    int rd,
    int rs1,
    int rs2
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b0110011;
    inst[11:7]  = rd;
    inst[14:12] = 3'b011;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[31:25] = 7'b0000000;
    return inst;
  endfunction

  protected function bit [31:0] inst_beq(
    int         rs1,
    int         rs2,
    bit [12:0]  offset
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b1100011;
    inst[7]     = offset[11];
    inst[11:8]  = offset[4:1];
    inst[14:12] = 3'b000;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[30:25] = offset[10:5];
    inst[31]    = offset[12];
    return inst;
  endfunction

  protected function bit [31:0] inst_bne(
    int         rs1,
    int         rs2,
    bit [12:0]  offset
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b1100011;
    inst[7]     = offset[11];
    inst[11:8]  = offset[4:1];
    inst[14:12] = 3'b001;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[30:25] = offset[10:5];
    inst[31]    = offset[12];
    return inst;
  endfunction

  protected function bit [31:0] inst_blt(
    int         rs1,
    int         rs2,
    bit [12:0]  offset
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b1100011;
    inst[7]     = offset[11];
    inst[11:8]  = offset[4:1];
    inst[14:12] = 3'b100;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[30:25] = offset[10:5];
    inst[31]    = offset[12];
    return inst;
  endfunction

  protected function bit [31:0] inst_bge(
    int         rs1,
    int         rs2,
    bit [12:0]  offset
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b1100011;
    inst[7]     = offset[11];
    inst[11:8]  = offset[4:1];
    inst[14:12] = 3'b101;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[30:25] = offset[10:5];
    inst[31]    = offset[12];
    return inst;
  endfunction

  protected function bit [31:0] inst_bltu(
    int         rs1,
    int         rs2,
    bit [12:0]  offset
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b1100011;
    inst[7]     = offset[11];
    inst[11:8]  = offset[4:1];
    inst[14:12] = 3'b110;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[30:25] = offset[10:5];
    inst[31]    = offset[12];
    return inst;
  endfunction

  protected function bit [31:0] inst_bgeu(
    int         rs1,
    int         rs2,
    bit [12:0]  offset
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b1100011;
    inst[7]     = offset[11];
    inst[11:8]  = offset[4:1];
    inst[14:12] = 3'b111;
    inst[19:15] = rs1;
    inst[24:20] = rs2;
    inst[30:25] = offset[10:5];
    inst[31]    = offset[12];
    return inst;
  endfunction

  protected function bit [31:0] inst_jal(
    int         rd,
    bit [20:0]  offset
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b1101111;
    inst[11:7]  = rd;
    inst[31:12] = {offset[20], offset[10:1], offset[11], offset[19:12]};
    return inst;
  endfunction

  protected function bit [31:0] inst_jalr(
    int         rd,
    int         rs,
    bit [11:0]  offset
  );
    bit [31:0]  inst;
    inst[6:0]   = 7'b1100111;
    inst[11:7]  = rd;
    inst[14:12] = 3'b000;
    inst[19:15] = rs;
    inst[31:20] = offset;
    return inst;
  endfunction

  protected task write_inst(
    tb_rice_bus_address offset,
    bit [31:0]          inst
  );
    tb_rice_bus_address address;
    tb_rice_bus_status  bus_status;
    address     = START_ADDRESS + offset;
    bus_status  = sequencer.inst_bus_sequencer.get_status();
    bus_status.memory.put(inst, 4'hF, 4, address, 0);
  endtask

  protected task write_data(
    tb_rice_bus_address address,
    bit [31:0]          data
  );
    tb_rice_bus_status  bus_status;
    bus_status  = sequencer.data_bus_sequencer.get_status();
    bus_status.memory.put(data, 4'hF, 4, address, 0);
  endtask

  protected task monito_data_bus_access(
    tb_rice_bus_address address,
    tb_rice_bus_strobe  strobe,
    tb_rice_bus_data    data
  );
    tb_rice_bus_item  bus_item;
    while (1) begin
      sequencer.data_bus_sequencer.get_item(bus_item);
      if ((bus_item.address == address) && (bus_item.strobe == strobe) && (bus_item.data == data)) begin
        return;
      end
    end
  endtask

  `tue_component_default_constructor(tb_rice_core_basic_test_base)
endclass
