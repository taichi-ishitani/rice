package rice_core_pkg;
  import  rice_riscv_pkg::*;

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

  typedef enum logic [2:0] {
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

  typedef struct packed {
    logic [3:0] pred;
    logic [3:0] succ;
    logic       fence;
    logic       fence_i;
  } rice_core_ordering_control;

  typedef struct packed {
    logic ebreak;
    logic ecall;
    logic mret;
  } rice_core_trap_control;

  typedef enum logic [2:0] {
    RICE_CORE_CSR_ACCESS_NONE = 3'b000,
    RICE_CORE_CSR_ACCESS_RW   = 3'b001,
    RICE_CORE_CSR_ACCESS_RWI  = 3'b101,
    RICE_CORE_CSR_ACCESS_RS   = 3'b010,
    RICE_CORE_CSR_ACCESS_RSI  = 3'b110,
    RICE_CORE_CSR_ACCESS_RC   = 3'b011,
    RICE_CORE_CSR_ACCESS_RCI  = 3'b111
  } rice_core_csr_access;

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
