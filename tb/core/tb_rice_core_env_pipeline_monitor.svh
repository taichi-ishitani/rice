class tb_rice_core_env_pipeline_monitor_item extends tue_object_base #(
  .BASE           (tb_rice_riscv_inst_item        ),
  .CONFIGURATION  (tb_rice_core_env_configuration ),
  .STATUS         (tb_rice_core_env_status        )
);
  longint id;
  bit     misaligned_pc;
  bit     illegal_instruction;
  bit     invalid_csr_access;

  `tue_object_default_constructor(tb_rice_core_env_pipeline_monitor_item)
  `uvm_object_utils_begin(tb_rice_core_env_pipeline_monitor_item)
    `uvm_field_int(id, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(misaligned_pc, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(illegal_instruction, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(invalid_csr_access, UVM_DEFAULT | UVM_BIN)
  `uvm_object_utils_end
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
  protected tb_rice_core_env_pipeline_if_proxy_base pipeline_if;
  protected longint                                 instruction_id;
  protected longint unsigned                        cycles;
  tb_rice_core_env_pipeline_monitor_item            if_items[$];
  tb_rice_core_env_pipeline_monitor_item            id_items[$];
  tb_rice_core_env_pipeline_monitor_item            ex_items[$];
  tb_rice_core_env_pipeline_monitor_item            wb_items[$];
  tb_rice_core_env_pipeline_sub_monitor_base        sub_monitors[$];

  task run_phase(uvm_phase phase);
    instruction_id  = 0;
    cycles          = 0;
    pipeline_if     = configuration.tb_context.pipeline_if;
    while (1) begin
      pipeline_if.wait_cb();
      ++cycles;
      monitor_pipeline();
    end
  endtask

  `define tb_rice_core_monitor_pipeline_item(PHASE) \
  pipeline_if.PHASE(item); \
  foreach (sub_monitors[__i]) begin \
    sub_monitors[__i].PHASE(cycles, item); \
  end

  protected task monitor_pipeline();
    tb_rice_core_env_pipeline_monitor_item item;

    if (pipeline_if.flush()) begin
      do_flush();
    end

    if (pipeline_if.inst_request_valid()) begin
      item  = create_monotor_item();
      `tb_rice_core_monitor_pipeline_item(start_if)
      if_items.push_back(item);
    end

    if (pipeline_if.if_valid()) begin
      item  = if_items.pop_front();
      `tb_rice_core_monitor_pipeline_item(end_if)
      `tb_rice_core_monitor_pipeline_item(start_id)
      id_items.push_back(item);
    end

    if (pipeline_if.id_valid()) begin
      item  = id_items.pop_front();
      `tb_rice_core_monitor_pipeline_item(end_id)
      `tb_rice_core_monitor_pipeline_item(start_ex)
      ex_items.push_back(item);
    end

    if (pipeline_if.ex_valid()) begin
      item  = ex_items.pop_front();
      `tb_rice_core_monitor_pipeline_item(end_ex)
      `tb_rice_core_monitor_pipeline_item(start_wb)
      wb_items.push_back(item);
    end

    if (pipeline_if.wb_valid()) begin
      item  = wb_items.pop_front();
      `tb_rice_core_monitor_pipeline_item(end_wb)
    end

    foreach (sub_monitors[i]) begin
      sub_monitors[i].end_monitor_cycle(cycles);
    end
  endtask

  protected function void do_flush();
    foreach (id_items[i]) begin
      foreach (sub_monitors[j]) begin
        sub_monitors[j].flush_id(cycles, id_items[i]);
      end
    end
    id_items.delete();

    foreach (if_items[i]) begin
      foreach (sub_monitors[j]) begin
        sub_monitors[j].flush_if(cycles, if_items[i]);
      end
    end
    if_items.delete();
  endfunction

  protected function tb_rice_core_env_pipeline_monitor_item create_monotor_item();
    tb_rice_core_env_pipeline_monitor_item item;
    item    = new();
    item.id = instruction_id++;
    return item;
  endfunction

  `undef  tb_rice_core_monitor_pipeline_item

  `tue_component_default_constructor(tb_rice_core_env_pipeline_monitor)
  `uvm_component_utils(tb_rice_core_env_pipeline_monitor)
endclass
