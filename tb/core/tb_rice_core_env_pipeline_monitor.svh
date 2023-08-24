class tb_rice_core_env_pipeline_monitor_item extends tue_object_base #(
  .BASE           (tb_rice_riscv_inst_item        ),
  .CONFIGURATION  (tb_rice_core_env_configuration ),
  .STATUS         (tb_rice_core_env_status        )
);
  longint id;
  bit     misaligned_pc;
  bit     illegal_instruction;
  bit     invalid_csr_access;

  function void start_if(tb_rice_core_env_pipeline_monitor_vif vif);
    pc    = vif.monitor_cb.inst_request_address;
    xlen  = 32;
  endfunction

  function void end_if(tb_rice_core_env_pipeline_monitor_vif vif);
    set_inst(vif.monitor_cb.if_result.inst);
  endfunction

  function void flush_if();
  endfunction

  function void start_id(tb_rice_core_env_pipeline_monitor_vif vif);
  endfunction

  function void end_id(tb_rice_core_env_pipeline_monitor_vif vif);
    rs1_value = vif.monitor_cb.id_result.rs1_value;
    rs2_value = vif.monitor_cb.id_result.rs2_value;
    imm_value = vif.monitor_cb.id_result.imm_value;
  endfunction

  function void flush_id();
  endfunction

  function void start_ex(tb_rice_core_env_pipeline_monitor_vif vif);
  endfunction

  function void end_ex(tb_rice_core_env_pipeline_monitor_vif vif);
    if (vif.monitor_cb.ex_result.error == '0) begin
      rd        = vif.monitor_cb.ex_result.rd;
      rd_value  = vif.monitor_cb.ex_result.rd_value;
    end
    else begin
      misaligned_pc       = vif.monitor_cb.ex_result.error.misaligned_pc;
      illegal_instruction = vif.monitor_cb.ex_result.error.illegal_instruction;
      invalid_csr_access  = vif.monitor_cb.ex_result.error.csr_access;
    end
  endfunction

  function void start_wb(tb_rice_core_env_pipeline_monitor_vif vif);
  endfunction

  function void end_wb(tb_rice_core_env_pipeline_monitor_vif vif);
  endfunction

  `tue_object_default_constructor(tb_rice_core_env_pipeline_monitor_item)
  `uvm_object_utils(tb_rice_core_env_pipeline_monitor_item)
endclass

class tb_rice_core_env_pipeline_sub_monitor_base extends tue_component #(
  .CONFIGURATION  (tb_rice_core_env_configuration ),
  .STATUS         (tb_rice_core_env_status        )
);
  virtual function void start_if(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
  endfunction

  virtual function void end_if(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
  endfunction

  virtual function void flush_if(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
  endfunction

  virtual function void start_id(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
  endfunction

  virtual function void end_id(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
  endfunction

  virtual function void flush_id(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
  endfunction

  virtual function void start_ex(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
  endfunction

  virtual function void end_ex(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
  endfunction

  virtual function void start_wb(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
  endfunction

  virtual function void end_wb(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
  endfunction

  virtual function void end_monitor_cycle(longint cycles);
  endfunction

  `tue_component_default_constructor(tb_rice_core_env_pipeline_sub_monitor_base)
endclass

class tb_rice_core_env_pipeline_monitor extends tue_component #(
  .CONFIGURATION  (tb_rice_core_env_configuration ),
  .STATUS         (tb_rice_core_env_status        )
);
  protected tb_rice_core_env_pipeline_monitor_vif vif;
  protected longint                               instruction_id;
  protected longint unsigned                      cycles;
  tb_rice_core_env_pipeline_monitor_item          if_items[$];
  tb_rice_core_env_pipeline_monitor_item          id_items[$];
  tb_rice_core_env_pipeline_monitor_item          ex_items[$];
  tb_rice_core_env_pipeline_monitor_item          wb_items[$];
  tb_rice_core_env_pipeline_sub_monitor_base      sub_monitors[$];

  task run_phase(uvm_phase phase);
    instruction_id  = 0;
    cycles          = 0;
    vif             = configuration.tb_context.pipeline_monitor_vif;
    while (1) @(vif.monitor_cb) begin
      ++cycles;
      monitor_pipeline();
    end
  endtask

  `define tb_rice_core_monitor_pipeline_item(PHASE) \
  item.PHASE(vif); \
  foreach (sub_monitors[__i]) begin \
    sub_monitors[__i].PHASE(cycles, item); \
  end

  protected task monitor_pipeline();
    tb_rice_core_env_pipeline_monitor_item  item;

    if (vif.monitor_cb.flush) begin
      do_flush();
    end

    if (vif.monitor_cb.inst_request_valid) begin
      item  = create_monotor_item();
      `tb_rice_core_monitor_pipeline_item(start_if)
      if_items.push_back(item);
    end

    if (vif.monitor_cb.if_valid) begin
      item  = if_items.pop_front();
      `tb_rice_core_monitor_pipeline_item(end_if)
      `tb_rice_core_monitor_pipeline_item(start_id)
      id_items.push_back(item);
    end

    if (vif.monitor_cb.id_valid) begin
      item  = id_items.pop_front();
      `tb_rice_core_monitor_pipeline_item(end_id)
      `tb_rice_core_monitor_pipeline_item(start_ex)
      ex_items.push_back(item);
    end

    if (vif.monitor_cb.ex_valid) begin
      item  = ex_items.pop_front();
      `tb_rice_core_monitor_pipeline_item(end_ex)
      `tb_rice_core_monitor_pipeline_item(start_wb)
      wb_items.push_back(item);
    end

    if (vif.monitor_cb.wb_valid) begin
      item  = wb_items.pop_front();
      `tb_rice_core_monitor_pipeline_item(end_wb)
    end

    foreach (sub_monitors[i]) begin
      sub_monitors[i].end_monitor_cycle(cycles);
    end
  endtask

  protected function void do_flush();
    foreach (id_items[i]) begin
      id_items[i].flush_id();
      foreach (sub_monitors[j]) begin
        sub_monitors[j].flush_id(cycles, id_items[i]);
      end
    end
    id_items.delete();

    foreach (if_items[i]) begin
      if_items[i].flush_if();
      foreach (sub_monitors[j]) begin
        sub_monitors[j].flush_if(cycles, if_items[i]);
      end
    end
    if_items.delete();
  endfunction

  protected function tb_rice_core_env_pipeline_monitor_item create_monotor_item();
    tb_rice_core_env_pipeline_monitor_item  item;
    item    = new();
    item.id = instruction_id++;
    return item;
  endfunction

  `undef  tb_rice_core_monitor_pipeline_item

  `tue_component_default_constructor(tb_rice_core_env_pipeline_monitor)
  `uvm_component_utils(tb_rice_core_env_pipeline_monitor)
endclass
