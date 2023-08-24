class tb_rice_core_env_cosim_monitor extends tb_rice_core_env_pipeline_sub_monitor_base;
  protected tb_rice_cosim_proxy cosim_proxy;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cosim_proxy = new("mon_instr", 0);
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    cosim_proxy.init();
  endfunction

  function void final_phase(uvm_phase phase);
    cosim_proxy.teardown();
  endfunction

  function void end_wb(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
    if (no_error(item)) begin
      cosim_proxy.gpr(cycles, item.rd, item.rd_value);
      if (is_csr_access(item)) begin
        monitor_csr(cycles, item);
      end
    end
    cosim_proxy.instr(cycles, 0, item.pc, item.inst_bits, 0);
  endfunction

  protected function bit no_error(tb_rice_core_env_pipeline_monitor_item item);
    return !(item.misaligned_pc || item.illegal_instruction || item.invalid_csr_access);
  endfunction

  protected function bit is_csr_access(tb_rice_core_env_pipeline_monitor_item item);
    return
      item.inst inside {
        TB_RICE_RISCV_INST_CSRRW, TB_RICE_RISCV_INST_CSRRS, TB_RICE_RISCV_INST_CSRRC,
        TB_RICE_RISCV_INST_CSRRWI, TB_RICE_RISCV_INST_CSRRSI, TB_RICE_RISCV_INST_CSRRCI
      };
  endfunction

  protected function void monitor_csr(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
    int     csr_address;
    longint rdata;
    longint wdata[2];

    csr_address = item.imm_value[11:0];
    rdata       = item.rd_value;
    case (item.inst)
      TB_RICE_RISCV_INST_CSRRW: begin
        wdata[0]  = item.rs1_value;
        wdata[1]  = wdata[0];
      end
      TB_RICE_RISCV_INST_CSRRS: begin
        wdata[0]  = item.rs1_value;
        wdata[1]  = rdata | wdata[0];
      end
      TB_RICE_RISCV_INST_CSRRC: begin
        wdata[0]  = item.rs1_value;
        wdata[1]  = rdata & (~wdata[0]);
      end
      TB_RICE_RISCV_INST_CSRRWI: begin
        wdata[0]  = item.rs1;
        wdata[1]  = wdata[0];
      end
      TB_RICE_RISCV_INST_CSRRSI: begin
        wdata[0]  = item.rs1;
        wdata[1]  = rdata | wdata[0];
      end
      TB_RICE_RISCV_INST_CSRRCI: begin
        wdata[0]  = item.rs1;
        wdata[1]  = rdata & (~wdata[0]);
      end
    endcase

    cosim_proxy.csr(cycles, csr_address, wdata[1]);
  endfunction

  `tue_component_default_constructor(tb_rice_core_env_cosim_monitor)
  `uvm_component_utils(tb_rice_core_env_cosim_monitor)
endclass
