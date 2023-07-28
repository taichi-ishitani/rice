package rice_core_pkg;
  typedef enum logic [6:0] {
    RICE_CORE_OPCODE_LOAD     = 7'b00_000_11,
    RICE_CORE_OPCODE_STORE    = 7'b01_000_11,
    RICE_CORE_OPCODE_BRANCH   = 7'b11_000_11,
    RICE_CORE_OPCODE_JALR     = 7'b11_001_11,
    RICE_CORE_OPCODE_MISC_MEM = 7'b00_011_11,
    RICE_CORE_OPCODE_JAL      = 7'b11_011_11,
    RICE_CORE_OPCODE_OP_IMM   = 7'b00_100_11,
    RICE_CORE_OPCODE_OP       = 7'b01_100_11,
    RICE_CORE_OPCODE_SYSTEM   = 7'b11_100_11,
    RICE_CORE_OPCODE_AUIPC    = 7'b00_101_11,
    RICE_CORE_OPCODE_LUI      = 7'b01_101_11
  } rice_core_opcode;

  typedef enum logic [2:0] {
    RICE_CORE_INST_TYPE_R,
    RICE_CORE_INST_TYPE_I,
    RICE_CORE_INST_TYPE_S,
    RICE_CORE_INST_TYPE_B,
    RICE_CORE_INST_TYPE_U,
    RICE_CORE_INST_TYPE_J
  } rice_core_inst_type;

  typedef logic [31:0]  rice_core_inst;
  typedef logic [4:0]   rice_core_rs;
  typedef logic [4:0]   rice_core_rd;

  typedef struct packed {
    logic [6:0]       funct7;
    rice_core_rs      rs2;
    rice_core_rs      rs1;
    logic [2:0]       funct3;
    rice_core_rd      rd;
    rice_core_opcode  opcode;
  } rice_core_inst_r_type;

  typedef struct packed {
    logic             imm_11;
    logic [10:0]      imm_10_0;
    rice_core_rs      rs1;
    logic [2:0]       funct3;
    rice_core_rd      rd;
    rice_core_opcode  opcode;
  } rice_core_inst_i_type;

  typedef struct packed {
    logic             imm_11;
    logic [5:0]       imm_10_5;
    rice_core_rs      rs2;
    rice_core_rs      rs1;
    logic [2:0]       funct3;
    logic [4:0]       imm_4_0;
    rice_core_opcode  opcode;
  } rice_core_inst_s_type;

  typedef struct packed {
    logic             imm_12;
    logic [5:0]       imm_10_5;
    rice_core_rs      rs2;
    rice_core_rs      rs1;
    logic [2:0]       funct3;
    logic [3:0]       imm_4_1;
    logic             imm_11;
    rice_core_opcode  opcode;
  } rice_core_inst_b_type;

  typedef struct packed {
    logic             imm_31;
    logic [18:0]      imm_30_12;
    rice_core_rd      rd;
    rice_core_opcode  opcode;
  } rice_core_inst_u_type;

  typedef struct packed {
    logic             imm_20;
    logic [9:0]       imm_10_1;
    logic             imm_11;
    logic [7:0]       imm_19_12;
    rice_core_rd      rd;
    rice_core_opcode  opcode;
  } rice_core_inst_j_type;

  function automatic rice_core_opcode get_opcode(rice_core_inst inst);
    return rice_core_opcode'(inst[0+:$bits(rice_core_opcode)]);
  endfunction

  function automatic rice_core_inst_type get_inst_type(rice_core_opcode opcode);
    case (opcode)
      RICE_CORE_OPCODE_OP_IMM,
      RICE_CORE_OPCODE_JALR,
      RICE_CORE_OPCODE_LOAD,
      RICE_CORE_OPCODE_MISC_MEM,
      RICE_CORE_OPCODE_SYSTEM:
        return RICE_CORE_INST_TYPE_I;
      RICE_CORE_OPCODE_LUI,
      RICE_CORE_OPCODE_AUIPC:
        return RICE_CORE_INST_TYPE_U;
      RICE_CORE_OPCODE_JAL:
        return RICE_CORE_INST_TYPE_J;
      RICE_CORE_OPCODE_BRANCH:
        return RICE_CORE_INST_TYPE_B;
      RICE_CORE_OPCODE_STORE:
        return RICE_CORE_INST_TYPE_S;
      default:
        return RICE_CORE_INST_TYPE_R;
    endcase
  endfunction

  typedef enum logic [31:0] {
    RICE_CORE_ALU_NONE,
    RICE_CORE_ALU_ADD
  } rice_core_alu_operation;

  typedef enum logic [31:0] {
    RICE_CORE_ALU_OPERAND_RS,
    RICE_CORE_ALU_OPERAND_IMM
  } rice_core_alu_operand;

  typedef enum logic [1:0] {
    RICE_CORE_MEMORY_ACCESS_NONE,
    RICE_CORE_MEMORY_ACCESS_STORE,
    RICE_CORE_MEMORY_ACCESS_LOAD
  } rice_core_memory_access_type;

  typedef enum logic [2:0] {
    RICE_CORE_MEMORY_ACCESS_MODE_B  = 3'b000,
    RICE_CORE_MEMORY_ACCESS_MODE_BU = 3'b100,
    RICE_CORE_MEMORY_ACCESS_MODE_H  = 3'b001,
    RICE_CORE_MEMORY_ACCESS_MODE_HU = 3'b101,
    RICE_CORE_MEMORY_ACCESS_MODE_W  = 3'b010
  } rice_core_memory_access_mode;

  typedef struct packed {
    rice_core_memory_access_type  access_type;
    rice_core_memory_access_mode  access_mode;
  } rice_core_memory_access;
endpackage
