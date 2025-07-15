typedef class tb_rice_core_env_pipeline_monitor_item;

virtual class tb_rice_core_env_pipeline_if_proxy_base;
  pure virtual function bit inst_request_valid();
  pure virtual function bit flush();

  pure virtual function bit if_valid();
  pure virtual function void start_if(tb_rice_core_env_pipeline_monitor_item inst_item);
  pure virtual function void end_if(tb_rice_core_env_pipeline_monitor_item inst_item);

  pure virtual function bit id_valid();
  pure virtual function void start_id(tb_rice_core_env_pipeline_monitor_item inst_item);
  pure virtual function void end_id(tb_rice_core_env_pipeline_monitor_item inst_item);

  pure virtual function bit ex_valid();
  pure virtual function void start_ex(tb_rice_core_env_pipeline_monitor_item inst_item);
  pure virtual function void end_ex(tb_rice_core_env_pipeline_monitor_item inst_item);

  pure virtual function bit wb_valid();
  pure virtual function void start_wb(tb_rice_core_env_pipeline_monitor_item inst_item);
  pure virtual function void end_wb(tb_rice_core_env_pipeline_monitor_item inst_item);

  pure virtual task wait_cb();
endclass

class tb_rice_core_env_pipeline_if_proxy #(
  type  VIF
) extends tb_rice_core_env_pipeline_if_proxy_base;
  protected VIF vif;

  function new(VIF vif);
    super.new();
    this.vif  = vif;
  endfunction

  function bit inst_request_valid();
    return vif.cb.inst_request_valid;
  endfunction

  function bit flush();
    return vif.cb.flush;
  endfunction

  function bit if_valid();
    return vif.cb.if_valid;
  endfunction

  function void start_if(tb_rice_core_env_pipeline_monitor_item inst_item);
    inst_item.pc    = vif.cb.inst_request_address;
    inst_item.xlen  = vif.xlen();
  endfunction

  function void end_if(tb_rice_core_env_pipeline_monitor_item inst_item);
    inst_item.set_inst(vif.cb.if_result.inst_bits);
  endfunction

  function bit id_valid();
    return vif.cb.id_valid;
  endfunction

  function void start_id(tb_rice_core_env_pipeline_monitor_item inst_item);
  endfunction

  function void end_id(tb_rice_core_env_pipeline_monitor_item inst_item);
    inst_item.rs1_value = vif.cb.id_result.rs1_value;
    inst_item.rs2_value = vif.cb.id_result.rs2_value;
    inst_item.imm_value = vif.cb.id_result.imm_value;
  endfunction

  function bit ex_valid();
    return vif.cb.ex_valid;
  endfunction

  function void start_ex(tb_rice_core_env_pipeline_monitor_item inst_item);
  endfunction

  function void end_ex(tb_rice_core_env_pipeline_monitor_item inst_item);
    if (vif.cb.ex_result.error === '0) begin
      inst_item.rd        = vif.cb.ex_result.rd;
      inst_item.rd_value  = vif.cb.ex_result.rd_value;
    end
    else begin
      inst_item.misaligned_pc       = vif.cb.ex_result.error.misaligned_pc;
      inst_item.illegal_instruction = vif.cb.ex_result.error.illegal_instruction;
      inst_item.invalid_csr_access  = vif.cb.ex_result.error.csr_access;
    end
  endfunction

  function bit wb_valid();
    return vif.cb.wb_valid;
  endfunction

  function void start_wb(tb_rice_core_env_pipeline_monitor_item inst_item);
  endfunction

  function void end_wb(tb_rice_core_env_pipeline_monitor_item inst_item);
  endfunction

  task wait_cb();
    @(vif.cb);
  endtask
endclass
