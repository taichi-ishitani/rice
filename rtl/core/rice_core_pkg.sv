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
    RICE_CORE_ALU_ADD,
    RICE_CORE_ALU_SUB,
    RICE_CORE_ALU_LT,
    RICE_CORE_ALU_LTU,
    RICE_CORE_ALU_XOR,
    RICE_CORE_ALU_OR,
    RICE_CORE_ALU_AND,
    RICE_CORE_ALU_SLL,
    RICE_CORE_ALU_SRL,
    RICE_CORE_ALU_SRA
  } rice_core_alu_command;

  typedef enum logic [31:0] {
    RICE_CORE_ALU_SOURCE_IMM_0,
    RICE_CORE_ALU_SOURCE_IMM_4,
    RICE_CORE_ALU_SOURCE_IMM,
    RICE_CORE_ALU_SOURCE_RS,
    RICE_CORE_ALU_SOURCE_PC
  } rice_core_alu_source;

  typedef struct packed {
    rice_core_alu_command command;
    rice_core_alu_source  source_1;
    rice_core_alu_source  source_2;
  } rice_core_alu_operation;

  typedef enum logic [31:0] {
    RICE_CORE_PC_CONTROL_NONE,
    RICE_CORE_PC_CONTROL_BEQ,
    RICE_CORE_PC_CONTROL_BNE,
    RICE_CORE_PC_CONTROL_BLT,
    RICE_CORE_PC_CONTROL_BGE
  } rice_core_pc_control;

  typedef struct packed {
    logic jal;
    logic jalr;
  } rice_core_jamp_operation;

  typedef struct packed {
    logic eq_ge;
    logic ne_lt;
  } rice_core_branch_operation;

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

  typedef enum logic [2:0] {
    RICE_CORE_CSR_ACCESS_NONE = 3'b000,
    RICE_CORE_CSR_ACCESS_RW   = 3'b001,
    RICE_CORE_CSR_ACCESS_RWI  = 3'b101,
    RICE_CORE_CSR_ACCESS_RS   = 3'b010,
    RICE_CORE_CSR_ACCESS_RSI  = 3'b110,
    RICE_CORE_CSR_ACCESS_RC   = 3'b011,
    RICE_CORE_CSR_ACCESS_RCI  = 3'b111
  } rice_core_csr_access;

  typedef struct packed {
    logic ebreak;
    logic ecall;
    logic mret;
  } rice_core_trap_control;

  typedef enum logic [1:0] {
    RICE_CORE_USER_MODE       = 2'b00,
    RICE_CORE_SUPERVISOR_MODE = 2'b01,
    RICE_CORE_MACHINE_MODE    = 2'b11
  } rice_core_privilege_level;

  typedef struct packed {
    logic store_amo_page_fault;
    logic laod_page_fault;
    logic instruction_page_fault;
    logic ecall_from_m_mode;
    logic __reserved;
    logic ecall_from_s_mode;
    logic ecall_from_u_mode;
    logic store_amo_access_fault;
    logic store_amo_address_misaligned;
    logic load_access_fault;
    logic load_address_misaligned;
    logic breakpoint;
    logic illegal_instruction;
    logic instruction_access_fault;
    logic instruction_address_misaligned;
  } rice_core_exception;

  localparam  bit RICE_CORE_DEBUG = `ifndef SYNTHESIS 1
                                    `else             0
                                    `endif;
endpackage
