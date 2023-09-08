`define rice_core_define_types(XLEN) \
typedef logic [XLEN-1:0]  rice_core_value; \
typedef logic [XLEN-1:0]  rice_core_pc; \
typedef struct packed { \
  logic         taken; \
  rice_core_pc  target_pc; \
} rice_core_bp_result; \
typedef struct packed { \
  logic         taken; \
  logic         not_taken; \
  logic         jamp; \
  rice_core_pc  pc; \
  rice_core_pc  target_pc; \
  logic [2:0]   misprediction; \
} rice_core_branch_result; \
typedef struct packed { \
  logic               valid; \
  rice_core_pc        pc; \
  rice_riscv_inst     inst; \
  rice_core_bp_result bp_result; \
} rice_core_if_result; \
typedef struct packed { \
  logic                       valid; \
  rice_core_pc                pc; \
  rice_riscv_inst             inst; \
  rice_riscv_rs               rs1; \
  rice_riscv_rs               rs2; \
  rice_riscv_rd               rd; \
  rice_core_value             rs1_value; \
  rice_core_value             rs2_value; \
  rice_core_value             imm_value; \
  rice_core_alu_operation     alu_operation; \
  rice_core_mul_operation     mul_operation; \
  rice_core_div_operation     div_operation; \
  rice_core_branch_operation  branch_operation; \
  rice_core_memory_access     memory_access; \
  rice_core_ordering_control  ordering_control; \
  rice_core_trap_control      trap_control; \
  rice_core_csr_access        csr_access; \
  rice_core_bp_result         bp_result; \
} rice_core_id_result; \
typedef struct packed { \
  logic               valid; \
  rice_core_ex_error  error; \
  rice_riscv_rd       rd; \
  rice_core_value     rd_value; \
} rice_core_ex_result;
