`define rice_core_define_types(XLEN) \
typedef logic [XLEN-1:0]  rice_core_value; \
typedef logic [XLEN-1:0]  rice_core_pc; \
typedef struct packed { \
  logic           valid; \
  rice_core_pc    pc; \
  rice_core_inst  inst; \
} rice_core_if_result; \
typedef struct packed { \
  logic                       valid; \
  rice_core_pc                pc; \
  rice_core_rs                rs1; \
  rice_core_rs                rs2; \
  rice_core_rd                rd; \
  rice_core_value             rs1_value; \
  rice_core_value             rs2_value; \
  rice_core_value             imm_value; \
  rice_core_alu_operation     alu_operation; \
  rice_core_jamp_operation    jamp_operation; \
  rice_core_branch_operation  branch_operation; \
  rice_core_memory_access     memory_access; \
  rice_core_csr_access        csr_access; \
} rice_core_id_result; \
typedef struct packed { \
  logic           valid; \
  rice_core_rd    rd; \
  rice_core_value rd_value; \
} rice_core_ex_result;
