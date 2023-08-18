class tb_rice_riscv_inst_item extends uvm_object;
  int                   xlen;
  longint unsigned      pc;
  bit [31:0]            inst_bits;
  tb_rice_riscv_inst    inst;
  tb_rice_riscv_opcode  opcode;
  int                   rd;
  int                   rs1;
  int                   rs2;
  bit [2:0]             funct3;
  bit [6:0]             funct7;
  bit [63:0]            rd_value;
  bit [63:0]            rs1_value;
  bit [63:0]            rs2_value;
  bit [63:0]            imm_value;

  function new(string name = "tb_rice_riscv_inst_item");
    super.new(name);
    rd  = -1;
    rs1 = -1;
    rs2 = -1;
  endfunction

  virtual function void set_inst(bit [31:0] inst_bits);
    this.inst_bits  = inst_bits;
    parse_inst_bits();
    determine_inst();
  endfunction

  virtual function string print_inst(int verbosity = 0);
    if (inst_bits == 0) begin
      return $sformatf("%s:", print_value(pc));
    end
    else if (verbosity == 1) begin
      return $sformatf("%s: %x", print_value(pc), inst_bits);
    end
    else begin
      return $sformatf("%s: %x %s", print_value(pc), inst_bits, get_inst_string());
    end
  endfunction

  protected function void parse_inst_bits();
    opcode  = tb_rice_riscv_opcode'(inst_bits[6:0]);
    case (get_inst_type(opcode))
      TB_RICE_RISCV_INST_R_TYPE:  parse_inst_r_type();
      TB_RICE_RISCV_INST_I_TYPE:  parse_inst_i_type();
      TB_RICE_RISCV_INST_S_TYPE:  parse_inst_s_type();
      TB_RICE_RISCV_INST_B_TYPE:  parse_inst_b_type();
      TB_RICE_RISCV_INST_U_TYPE:  parse_inst_u_type();
      TB_RICE_RISCV_INST_J_TYPE:  parse_inst_j_type();
    endcase
  endfunction

  protected function tb_rice_riscv_inst_type get_inst_type(tb_rice_riscv_opcode opcode);
    case (opcode)
      TB_RICE_RISCV_OPCODE_OP:
        return TB_RICE_RISCV_INST_R_TYPE;
      TB_RICE_RISCV_OPCODE_OP_IMM,
      TB_RICE_RISCV_OPCODE_JALR,
      TB_RICE_RISCV_OPCODE_LOAD,
      TB_RICE_RISCV_OPCODE_MISC_MEM,
      TB_RICE_RISCV_OPCODE_SYSTEM:
        return TB_RICE_RISCV_INST_I_TYPE;
      TB_RICE_RISCV_OPCODE_STORE:
        return TB_RICE_RISCV_INST_S_TYPE;
      TB_RICE_RISCV_OPCODE_BRANCH:
        return TB_RICE_RISCV_INST_B_TYPE;
      TB_RICE_RISCV_OPCODE_LUI,
      TB_RICE_RISCV_OPCODE_AUIPC:
        return TB_RICE_RISCV_INST_U_TYPE;
      TB_RICE_RISCV_OPCODE_JAL:
        return TB_RICE_RISCV_INST_J_TYPE;
    endcase
  endfunction

  protected function void parse_inst_r_type();
    rd      = inst_bits[7+:5];
    funct3  = inst_bits[12+:3];
    rs1     = inst_bits[15+:5];
    rs2     = inst_bits[20+:5];
    funct7  = inst_bits[25+:7];
  endfunction

  protected function void parse_inst_i_type();
    bit [11:0]  imm = '0;
    rd                = inst_bits[7+:5];
    funct3            = inst_bits[12+:3];
    rs1               = inst_bits[15+:5];
    imm               = inst_bits[20+:12];
    imm_value[11:0]   = imm;
    imm_value[63:12]  = '{default: imm[11]};
  endfunction

  protected function void parse_inst_s_type();
    bit [11:0]  imm = '0;
    imm[4:0]          = inst_bits[7+:5];
    funct3            = inst_bits[12+:3];
    rs1               = inst_bits[15+:5];
    rs2               = inst_bits[20+:5];
    imm               = inst_bits[25+:7];
    imm_value[11:0]   = imm;
    imm_value[63:12]  = '{default: imm[11]};
  endfunction

  protected function void parse_inst_b_type();
    bit [12:0]  imm = '0;
    {imm[4:1], imm[11]}   = inst_bits[7+:5];
    funct3                = inst_bits[12+:3];
    rs1                   = inst_bits[15+:5];
    rs2                   = inst_bits[20+:5];
    {imm[12], imm[10:5]}  = inst_bits[25+:7];
    imm_value[12:0]       = imm;
    imm_value[63:13]      = '{default: imm[12]};
  endfunction

  protected function void parse_inst_u_type();
    bit [31:0]  imm = '0;
    rd                = inst_bits[7+:5];
    imm[12+:20]       = inst_bits[12+:20];
    imm_value[31:0]   = imm;
    imm_value[63:32]  = '{default: imm[31]};
  endfunction

  protected function void parse_inst_j_type();
    bit [20:0]  imm = '0;
    rd                            = inst_bits[7+:5];
    imm[19:12]                    = inst_bits[12+:8];
    {imm[20], imm[10:1], imm[11]} = inst_bits[20+:12];
    imm_value[20:0]               = imm;
    imm_value[63:21]              = '{default: imm[20]};
  endfunction

  protected function void determine_inst();
    inst  = TB_RICE_RISCV_INST_NA;

    case (opcode)
      TB_RICE_RISCV_OPCODE_LUI: begin
        inst  = TB_RICE_RISCV_INST_LUI;
      end
      TB_RICE_RISCV_OPCODE_AUIPC: begin
        inst  = TB_RICE_RISCV_INST_AUIPC;
      end
      TB_RICE_RISCV_OPCODE_JAL: begin
        inst  = TB_RICE_RISCV_INST_JAL;
      end
      TB_RICE_RISCV_OPCODE_JALR: begin
        if (funct3 == 3'b000) begin
          inst  = TB_RICE_RISCV_INST_JALR;
        end
      end
      TB_RICE_RISCV_OPCODE_BRANCH: begin
        case (funct3)
          3'b000: inst  = TB_RICE_RISCV_INST_BEQ;
          3'b001: inst  = TB_RICE_RISCV_INST_BNE;
          3'b100: inst  = TB_RICE_RISCV_INST_BLT;
          3'b101: inst  = TB_RICE_RISCV_INST_BGE;
          3'b110: inst  = TB_RICE_RISCV_INST_BLTU;
          3'b111: inst  = TB_RICE_RISCV_INST_BGEU;
        endcase
      end
      TB_RICE_RISCV_OPCODE_LOAD: begin
        case (funct3)
          3'b000: inst  = TB_RICE_RISCV_INST_LB;
          3'b001: inst  = TB_RICE_RISCV_INST_LH;
          3'b010: inst  = TB_RICE_RISCV_INST_LW;
          3'b100: inst  = TB_RICE_RISCV_INST_LBU;
          3'b101: inst  = TB_RICE_RISCV_INST_LHU;
        endcase
      end
      TB_RICE_RISCV_OPCODE_STORE: begin
        case (funct3)
          3'b000: inst  = TB_RICE_RISCV_INST_SB;
          3'b001: inst  = TB_RICE_RISCV_INST_SH;
          3'b010: inst  = TB_RICE_RISCV_INST_SW;
        endcase
      end
      TB_RICE_RISCV_OPCODE_OP_IMM: begin
        case ({funct3, imm_value[11:0]}) inside
          {3'b000, 12'b????????????}: inst  = TB_RICE_RISCV_INST_ADDI;
          {3'b010, 12'b????????????}: inst  = TB_RICE_RISCV_INST_SLTI;
          {3'b011, 12'b????????????}: inst  = TB_RICE_RISCV_INST_SLTIU;
          {3'b100, 12'b????????????}: inst  = TB_RICE_RISCV_INST_XORI;
          {3'b110, 12'b????????????}: inst  = TB_RICE_RISCV_INST_ORI;
          {3'b111, 12'b????????????}: inst  = TB_RICE_RISCV_INST_ANDI;
          {3'b001, 12'b0000000?????}: inst  = TB_RICE_RISCV_INST_SLLI;
          {3'b101, 12'b0000000?????}: inst  = TB_RICE_RISCV_INST_SRLI;
          {3'b101, 12'b0100000?????}: inst  = TB_RICE_RISCV_INST_SRAI;
        endcase
      end
      TB_RICE_RISCV_OPCODE_OP: begin
        case ({funct3, funct7})
          {3'b000, 7'b0000000}: inst  = TB_RICE_RISCV_INST_ADD;
          {3'b000, 7'b0100000}: inst  = TB_RICE_RISCV_INST_SUB;
          {3'b001, 7'b0000000}: inst  = TB_RICE_RISCV_INST_SLL;
          {3'b010, 7'b0000000}: inst  = TB_RICE_RISCV_INST_SLT;
          {3'b011, 7'b0000000}: inst  = TB_RICE_RISCV_INST_SLTU;
          {3'b100, 7'b0000000}: inst  = TB_RICE_RISCV_INST_XOR;
          {3'b101, 7'b0000000}: inst  = TB_RICE_RISCV_INST_SRL;
          {3'b101, 7'b0100000}: inst  = TB_RICE_RISCV_INST_SRA;
          {3'b110, 7'b0000000}: inst  = TB_RICE_RISCV_INST_OR;
          {3'b111, 7'b0000000}: inst  = TB_RICE_RISCV_INST_AND;
          {3'b000, 7'b0000001}: inst  = TB_RICE_RISCV_INTS_MUL;
          {3'b001, 7'b0000001}: inst  = TB_RICE_RISCV_INTS_MULH;
          {3'b010, 7'b0000001}: inst  = TB_RICE_RISCV_INTS_MULHSU;
          {3'b011, 7'b0000001}: inst  = TB_RICE_RISCV_INTS_MULHU;
        endcase
      end
      TB_RICE_RISCV_OPCODE_MISC_MEM: begin
        case (1'b1)
          ((rd == 0) && (funct3 == 3'b000) && (rs1 == 0) && (imm_value[11:0] ==? 12'b0000????????)):
            inst  = TB_RICE_RISCV_INST_FENCE;
          ((rd == 0) && (funct3 == 3'b001) && (rs1 == 0) && (imm_value[11:0] ==? 12'b000000000000)):
            inst  = TB_RICE_RISCV_INST_FENCE_I;
        endcase
      end
      TB_RICE_RISCV_OPCODE_SYSTEM: begin
        case (1'b1)
          ((rd == 0) && (funct3 == 3'b000) && (rs1 == 0) && (imm_value[11:0] == 12'b000000000000)):
            inst  = TB_RICE_RISCV_INST_ECALL;
          ((rd == 0) && (funct3 == 3'b000) && (rs1 == 0) && (imm_value[11:0] == 12'b000000000001)):
            inst  = TB_RICE_RISCV_INST_EBREAK;
          ((rd == 0) && (funct3 == 3'b000) && (rs1 == 0) && (imm_value[11:0] == 12'b001100000010)):
            inst  = TB_RICE_RISCV_INST_MRET;
          ((funct3 == 3'b001)):
            inst  = TB_RICE_RISCV_INST_CSRRW;
          ((funct3 == 3'b010)):
            inst  = TB_RICE_RISCV_INST_CSRRS;
          ((funct3 == 3'b011)):
            inst  = TB_RICE_RISCV_INST_CSRRC;
          ((funct3 == 3'b101)):
            inst  = TB_RICE_RISCV_INST_CSRRWI;
          ((funct3 == 3'b110)):
            inst  = TB_RICE_RISCV_INST_CSRRSI;
          ((funct3 == 3'b111)):
            inst  = TB_RICE_RISCV_INST_CSRRCI;
        endcase
      end
    endcase

    if (inst == TB_RICE_RISCV_INST_NA) begin
      `uvm_warning(
        "INVALID_INST",
        $sformatf("invalid instruction code: pc %h instruction %h", pc, inst_bits
      ))
    end
  endfunction

  protected function string get_inst_name();
    string  prefix;
    string  name;
    int     i;
    int     j;
    prefix  = "TB_RICE_RISCV_INST_";
    name    = inst.name();
    i       = prefix.len();
    j       = name.len() - 1;
    return name.substr(i, j);
  endfunction

  protected function string get_inst_string();
    string  inst_name;

    inst_name = get_inst_name();
    case (inst)
      TB_RICE_RISCV_INST_SLLI,
      TB_RICE_RISCV_INST_SRLI,
      TB_RICE_RISCV_INST_SRAI:
        return $sformatf("%s rd: x%0d rs1: x%0d shamt: %0d", inst_name, rd, rs1, imm_value[4:0]);
      TB_RICE_RISCV_INST_FENCE:
        return $sformatf("%s succ: %b pred: %b", inst_name, imm_value[0+:4], imm_value[4+:4]);
      TB_RICE_RISCV_INST_FENCE_I:
        return inst_name;
      TB_RICE_RISCV_INST_ECALL,
      TB_RICE_RISCV_INST_EBREAK:
        return inst_name;
      TB_RICE_RISCV_INST_CSRRW,
      TB_RICE_RISCV_INST_CSRRS,
      TB_RICE_RISCV_INST_CSRRC:
        return $sformatf("%s rd: x%0d csr: %0h rs1: x%0x", inst_name, rd, imm_value[11:0], rs1);
      TB_RICE_RISCV_INST_CSRRWI,
      TB_RICE_RISCV_INST_CSRRSI,
      TB_RICE_RISCV_INST_CSRRCI:
        return $sformatf("%s rd: x%0d csr: %0h zimm: %b", inst_name, rd, imm_value[11:0], rs1[4:0]);
      TB_RICE_RISCV_INST_MRET:
        return inst_name;
    endcase

    case (get_inst_type(opcode))
      TB_RICE_RISCV_INST_R_TYPE:
        return $sformatf("%s rd: x%0d rs1: x%0d rs2: x%0d", inst_name, rd, rs1, rs2);
      TB_RICE_RISCV_INST_I_TYPE:
        return $sformatf("%s rd: x%0d rs1: x%0d imm: %s", inst_name, rd, rs1, print_value(imm_value));
      TB_RICE_RISCV_INST_S_TYPE,
      TB_RICE_RISCV_INST_B_TYPE:
        return $sformatf("%s rs1: x%0d rs2: x%0d imm: %s", inst_name, rs1, rs2, print_value(imm_value));
      TB_RICE_RISCV_INST_U_TYPE,
      TB_RICE_RISCV_INST_J_TYPE:
        return $sformatf("%s rd: x%0d imm: %s", inst_name, rd, print_value(imm_value));
    endcase
  endfunction

  protected function string print_value(bit [63:0] value);
    if (xlen == 32) begin
      bit [31:0]  v = value;
      return $sformatf("%x", v);
    end
    else begin
      return $sformatf("%x", value);
    end
  endfunction

  `uvm_object_utils_begin(tb_rice_riscv_inst_item)
    `uvm_field_int(xlen, UVM_DEFAULT | UVM_NOPRINT)
    `uvm_field_int(pc, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(inst_bits, UVM_DEFAULT | UVM_HEX)
    `uvm_field_enum(tb_rice_riscv_inst, inst, UVM_DEFAULT)
    `uvm_field_enum(tb_rice_riscv_opcode, opcode, UVM_DEFAULT)
    `uvm_field_int(rd, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(rs1, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(rs2, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(funct3, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(funct7, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(rd_value, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(rs1_value, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(rs2_value, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(imm_value, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass
