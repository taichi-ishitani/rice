package rice_riscv_inst_matcher_pkg;
  import  rice_riscv_pkg::*;

  function automatic logic match_lui(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxxxxxxxxxx, RICE_RISCV_OPCODE_LUI};
  endfunction

  function automatic logic match_auipc(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxxxxxxxxxx, RICE_RISCV_OPCODE_AUIPC};
  endfunction

  function automatic logic match_jal(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxxxxxxxxxx, RICE_RISCV_OPCODE_JAL};
  endfunction

  function automatic logic match_jalr(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx000xxxxx, RICE_RISCV_OPCODE_JALR};
  endfunction

  function automatic logic match_beq(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx000xxxxx, RICE_RISCV_OPCODE_BRANCH};
  endfunction

  function automatic logic match_bne(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx001xxxxx, RICE_RISCV_OPCODE_BRANCH};
  endfunction

  function automatic logic match_blt(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx100xxxxx, RICE_RISCV_OPCODE_BRANCH};
  endfunction

  function automatic logic match_bge(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx101xxxxx, RICE_RISCV_OPCODE_BRANCH};
  endfunction

  function automatic logic match_bltu(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx110xxxxx, RICE_RISCV_OPCODE_BRANCH};
  endfunction

  function automatic logic match_bgeu(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx111xxxxx, RICE_RISCV_OPCODE_BRANCH};
  endfunction

  function automatic logic match_lb(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx000xxxxx, RICE_RISCV_OPCODE_LOAD};
  endfunction

  function automatic logic match_lh(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx001xxxxx, RICE_RISCV_OPCODE_LOAD};
  endfunction

  function automatic logic match_lw(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx010xxxxx, RICE_RISCV_OPCODE_LOAD};
  endfunction

  function automatic logic match_lbu(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx100xxxxx, RICE_RISCV_OPCODE_LOAD};
  endfunction

  function automatic logic match_lhu(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx101xxxxx, RICE_RISCV_OPCODE_LOAD};
  endfunction

  function automatic logic match_sb(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx000xxxxx, RICE_RISCV_OPCODE_STORE};
  endfunction

  function automatic logic match_sh(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx001xxxxx, RICE_RISCV_OPCODE_STORE};
  endfunction

  function automatic logic match_sw(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx010xxxxx, RICE_RISCV_OPCODE_STORE};
  endfunction

  function automatic logic match_addi(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx000xxxxx, RICE_RISCV_OPCODE_OP_IMM};
  endfunction

  function automatic logic match_slti(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx010xxxxx, RICE_RISCV_OPCODE_OP_IMM};
  endfunction

  function automatic logic match_sltiu(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx011xxxxx, RICE_RISCV_OPCODE_OP_IMM};
  endfunction

  function automatic logic match_xori(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx100xxxxx, RICE_RISCV_OPCODE_OP_IMM};
  endfunction

  function automatic logic match_ori(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx110xxxxx, RICE_RISCV_OPCODE_OP_IMM};
  endfunction

  function automatic logic match_andi(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx111xxxxx, RICE_RISCV_OPCODE_OP_IMM};
  endfunction

  function automatic logic match_slli(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000xxxxxxxxxx001xxxxx, RICE_RISCV_OPCODE_OP_IMM};
  endfunction

  function automatic logic match_srli(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000xxxxxxxxxx101xxxxx, RICE_RISCV_OPCODE_OP_IMM};
  endfunction

  function automatic logic match_srai(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0100000xxxxxxxxxx101xxxxx, RICE_RISCV_OPCODE_OP_IMM};
  endfunction

  function automatic logic match_add(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000xxxxxxxxxx000xxxxx, RICE_RISCV_OPCODE_OP};
  endfunction

  function automatic logic match_sub(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0100000xxxxxxxxxx000xxxxx, RICE_RISCV_OPCODE_OP};
  endfunction

  function automatic logic match_sll(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000xxxxxxxxxx001xxxxx, RICE_RISCV_OPCODE_OP};
  endfunction

  function automatic logic match_slt(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000xxxxxxxxxx010xxxxx, RICE_RISCV_OPCODE_OP};
  endfunction

  function automatic logic match_sltu(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000xxxxxxxxxx011xxxxx, RICE_RISCV_OPCODE_OP};
  endfunction

  function automatic logic match_xor(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000xxxxxxxxxx100xxxxx, RICE_RISCV_OPCODE_OP};
  endfunction

  function automatic logic match_srl(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000xxxxxxxxxx101xxxxx, RICE_RISCV_OPCODE_OP};
  endfunction

  function automatic logic match_sra(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0100000xxxxxxxxxx101xxxxx, RICE_RISCV_OPCODE_OP};
  endfunction

  function automatic logic match_or(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000xxxxxxxxxx110xxxxx, RICE_RISCV_OPCODE_OP};
  endfunction

  function automatic logic match_and(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000xxxxxxxxxx111xxxxx, RICE_RISCV_OPCODE_OP};
  endfunction

  function automatic logic match_fence(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000xxxxxxxx0000000000000, RICE_RISCV_OPCODE_MISC_MEM};
  endfunction

  function automatic logic match_fence_i(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx001xxxxx, RICE_RISCV_OPCODE_MISC_MEM};
  endfunction

  function automatic logic match_ecall(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000000000000000000000, RICE_RISCV_OPCODE_SYSTEM};
  endfunction

  function automatic logic match_ebreak(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0000000000010000000000000, RICE_RISCV_OPCODE_SYSTEM};
  endfunction

  function automatic logic match_mret(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'b0011000000100000000000000, RICE_RISCV_OPCODE_SYSTEM};
  endfunction

  function automatic logic match_csrrw(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx001xxxxx, RICE_RISCV_OPCODE_SYSTEM};
  endfunction

  function automatic logic match_csrrs(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx010xxxxx, RICE_RISCV_OPCODE_SYSTEM};
  endfunction

  function automatic logic match_csrrc(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx011xxxxx, RICE_RISCV_OPCODE_SYSTEM};
  endfunction

  function automatic logic match_csrrwi(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx101xxxxx, RICE_RISCV_OPCODE_SYSTEM};
  endfunction

  function automatic logic match_csrrsi(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx110xxxxx, RICE_RISCV_OPCODE_SYSTEM};
  endfunction

  function automatic logic match_csrrci(rice_riscv_inst inst_bits);
    return inst_bits ==? {25'bxxxxxxxxxxxxxxxxx111xxxxx, RICE_RISCV_OPCODE_SYSTEM};
  endfunction
endpackage
