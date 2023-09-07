package rice_riscv_pkg;
  localparam  int RICE_RISCV_RF_SIZE  = 32;

  typedef enum logic [6:0] {
    RICE_RISCV_OPCODE_LOAD      = 7'b00_000_11,
    RICE_RISCV_OPCODE_STORE     = 7'b01_000_11,
    RICE_RISCV_OPCODE_BRANCH    = 7'b11_000_11,
    RICE_RISCV_OPCODE_JALR      = 7'b11_001_11,
    RICE_RISCV_OPCODE_MISC_MEM  = 7'b00_011_11,
    RICE_RISCV_OPCODE_JAL       = 7'b11_011_11,
    RICE_RISCV_OPCODE_OP_IMM    = 7'b00_100_11,
    RICE_RISCV_OPCODE_OP        = 7'b01_100_11,
    RICE_RISCV_OPCODE_SYSTEM    = 7'b11_100_11,
    RICE_RISCV_OPCODE_AUIPC     = 7'b00_101_11,
    RICE_RISCV_OPCODE_LUI       = 7'b01_101_11
  } rice_riscv_opcode;

  typedef enum logic [2:0] {
    RICE_RISCV_INST_TYPE_R,
    RICE_RISCV_INST_TYPE_I,
    RICE_RISCV_INST_TYPE_S,
    RICE_RISCV_INST_TYPE_B,
    RICE_RISCV_INST_TYPE_U,
    RICE_RISCV_INST_TYPE_J
  } rice_riscv_inst_type;

  typedef logic [31:0]  rice_riscv_inst;
  typedef logic [4:0]   rice_riscv_rs;
  typedef logic [4:0]   rice_riscv_rd;

  typedef struct packed {
    logic [6:0]       funct7;
    rice_riscv_rs     rs2;
    rice_riscv_rs     rs1;
    logic [2:0]       funct3;
    rice_riscv_rd     rd;
    rice_riscv_opcode opcode;
  } rice_riscv_inst_r_type;

  typedef struct packed {
    logic             imm_11;
    logic [10:0]      imm_10_0;
    rice_riscv_rs     rs1;
    logic [2:0]       funct3;
    rice_riscv_rd     rd;
    rice_riscv_opcode opcode;
  } rice_riscv_inst_i_type;

  typedef struct packed {
    logic             imm_11;
    logic [5:0]       imm_10_5;
    rice_riscv_rs     rs2;
    rice_riscv_rs     rs1;
    logic [2:0]       funct3;
    logic [4:0]       imm_4_0;
    rice_riscv_opcode opcode;
  } rice_riscv_inst_s_type;

  typedef struct packed {
    logic             imm_12;
    logic [5:0]       imm_10_5;
    rice_riscv_rs     rs2;
    rice_riscv_rs     rs1;
    logic [2:0]       funct3;
    logic [3:0]       imm_4_1;
    logic             imm_11;
    rice_riscv_opcode opcode;
  } rice_riscv_inst_b_type;

  typedef struct packed {
    logic             imm_31;
    logic [18:0]      imm_30_12;
    rice_riscv_rd     rd;
    rice_riscv_opcode opcode;
  } rice_riscv_inst_u_type;

  typedef struct packed {
    logic             imm_20;
    logic [9:0]       imm_10_1;
    logic             imm_11;
    logic [7:0]       imm_19_12;
    rice_riscv_rd     rd;
    rice_riscv_opcode opcode;
  } rice_riscv_inst_j_type;

  function automatic rice_riscv_opcode get_opcode(rice_riscv_inst inst);
    return rice_riscv_opcode'(inst[0+:$bits(rice_riscv_opcode)]);
  endfunction

  function automatic rice_riscv_inst_type get_inst_type(rice_riscv_opcode opcode);
    case (opcode)
      RICE_RISCV_OPCODE_OP_IMM,
      RICE_RISCV_OPCODE_JALR,
      RICE_RISCV_OPCODE_LOAD,
      RICE_RISCV_OPCODE_MISC_MEM,
      RICE_RISCV_OPCODE_SYSTEM:
        return RICE_RISCV_INST_TYPE_I;
      RICE_RISCV_OPCODE_LUI,
      RICE_RISCV_OPCODE_AUIPC:
        return RICE_RISCV_INST_TYPE_U;
      RICE_RISCV_OPCODE_JAL:
        return RICE_RISCV_INST_TYPE_J;
      RICE_RISCV_OPCODE_BRANCH:
        return RICE_RISCV_INST_TYPE_B;
      RICE_RISCV_OPCODE_STORE:
        return RICE_RISCV_INST_TYPE_S;
      default:
        return RICE_RISCV_INST_TYPE_R;
    endcase
  endfunction
endpackage
