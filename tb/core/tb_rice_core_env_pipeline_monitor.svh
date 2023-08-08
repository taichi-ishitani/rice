class tb_rice_core_env_pipeline_monitor_item extends tue_object_base #(
  .BASE           (tb_rice_riscv_inst_item        ),
  .CONFIGURATION  (tb_rice_core_env_configuration ),
  .STATUS         (tb_rice_core_env_status        )
);
  longint id;

  function void start_if(
    input tb_rice_core_env_pipeline_monitor_vif vif,
    ref   string                                log_commands[$]
  );
    pc    = vif.monitor_cb.inst_request_address;
    xlen  = 32;
    log_commands.push_back($sformatf("I\t%0d\t%0d\t%0d", id, id, 0));
    log_commands.push_back($sformatf("S\t%0d\t%0d\t%s", id, 0, "if"));
  endfunction

  function void end_if(
    input tb_rice_core_env_pipeline_monitor_vif vif,
    ref   string                                log_commands[$]
  );
    set_inst(vif.monitor_cb.if_result.inst);
    log_commands.push_back($sformatf("E\t%0d\t%0d\t%s", id, 0, "if"));
  endfunction

  function void flush_if(ref string log_commands[$]);
    add_inst_label(log_commands);
    log_commands.push_back($sformatf("R\t%0d\t%0d\t%0d", id, 0, 1));
  endfunction

  function void start_id(
    input tb_rice_core_env_pipeline_monitor_vif vif,
    ref   string                                log_commands[$]
  );
    log_commands.push_back($sformatf("S\t%0d\t%0d\t%s", id, 0, "id"));
  endfunction

  function void end_id(
    input tb_rice_core_env_pipeline_monitor_vif vif,
    ref   string                                log_commands[$]
  );
    log_commands.push_back($sformatf("E\t%0d\t%0d\t%s", id, 0, "id"));
  endfunction

  function void flush_id(ref string log_commands[$]);
    add_inst_label(log_commands);
    log_commands.push_back($sformatf("R\t%0d\t%0d\t%0d", id, 0, 1));
  endfunction

  function void start_ex(
    input tb_rice_core_env_pipeline_monitor_vif vif,
    ref   string                                log_commands[$]
  );
    log_commands.push_back($sformatf("S\t%0d\t%0d\t%s", id, 0, "ex"));
  endfunction

  function void end_ex(
    input tb_rice_core_env_pipeline_monitor_vif vif,
    ref   string                                log_commands[$]
  );
    log_commands.push_back($sformatf("E\t%0d\t%0d\t%s", id, 0, "ex"));
  endfunction

  function void start_wb(
    input tb_rice_core_env_pipeline_monitor_vif vif,
    ref   string                                log_commands[$]
  );
    log_commands.push_back($sformatf("S\t%0d\t%0d\t%s", id, 0, "wb"));
  endfunction

  function void end_wb(
    input tb_rice_core_env_pipeline_monitor_vif vif,
    ref   string                                log_commands[$]
  );
    add_inst_label(log_commands);
    log_commands.push_back($sformatf("E\t%0d\t%0d\t%s", id, 0, "wb"));
  endfunction

  protected function void add_inst_label(ref string log_commands[$]);
    log_commands.push_back($sformatf("L\t%0d\t%0d\t%s", id, 0, print_inst()));
  endfunction

  `tue_object_default_constructor(tb_rice_core_env_pipeline_monitor_item)
  `uvm_object_utils(tb_rice_core_env_pipeline_monitor_item)
endclass

class tb_rice_core_env_pipeline_monitor extends tue_component #(
  .CONFIGURATION  (tb_rice_core_env_configuration ),
  .STATUS         (tb_rice_core_env_status        )
);
  protected tb_rice_core_env_pipeline_monitor_vif vif;
  protected int                                   fd;
  protected longint                               instruction_id;
  protected longint unsigned                      cycles;
  protected longint unsigned                      cycles_latest;
  tb_rice_core_env_pipeline_monitor_item          if_items[$];
  tb_rice_core_env_pipeline_monitor_item          id_items[$];
  tb_rice_core_env_pipeline_monitor_item          ex_items[$];
  tb_rice_core_env_pipeline_monitor_item          wb_items[$];

  task run_phase(uvm_phase phase);
    string  log_commands[$];

    instruction_id  = 0;
    cycles          = 0;
    cycles_latest   = 0;
    vif             = configuration.tb_context.pipeline_monitor_vif;
    fd              = open_trace_file();
    while (1) @(vif.monitor_cb) begin
      ++cycles;
      monitor_pipeline(log_commands);
      if (log_commands.size() > 0) begin
        output_log_commands(log_commands);
        log_commands.delete();
        cycles_latest = cycles;
      end
    end
  endtask

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    close_trace_file();
  endfunction

  protected function int open_trace_file();
    int fd;

    fd  = $fopen(configuration.pipeline_trace_file, "w");
    if (fd == 0) begin
      `uvm_fatal(
        "PIPELINE_TRACE",
        $sformatf("cannot open such file: %s", configuration.pipeline_trace_file)
      )
    end

    $fdisplay(fd, "Kanata\t0004");
    $fdisplay(fd, "C=\t%0d", cycles);

    return fd;
  endfunction

  protected function void close_trace_file();
    $fclose(fd);
  endfunction

  protected task monitor_pipeline(ref string log_commands[$]);
    tb_rice_core_env_pipeline_monitor_item  item;

    if (vif.monitor_cb.flush) begin
      foreach (id_items[i]) begin
        id_items[i].flush_id(log_commands);
      end
      id_items.delete();

      foreach (if_items[i]) begin
        if_items[i].flush_if(log_commands);
      end
      if_items.delete();
    end

    if (vif.monitor_cb.inst_request_valid) begin
      item  = create_monotor_item();
      item.start_if(vif, log_commands);
      if_items.push_back(item);
    end

    if (vif.monitor_cb.if_valid) begin
      item  = if_items.pop_front();
      item.end_if(vif, log_commands);
      item.start_id(vif, log_commands);
      id_items.push_back(item);
    end

    if (vif.monitor_cb.id_valid) begin
      item  = id_items.pop_front();
      item.end_id(vif, log_commands);
      item.start_ex(vif, log_commands);
      ex_items.push_back(item);
    end

    if (vif.monitor_cb.ex_valid) begin
      item  = ex_items.pop_front();
      item.end_ex(vif, log_commands);
      item.start_wb(vif, log_commands);
      wb_items.push_back(item);
    end

    if (vif.monitor_cb.wb_valid) begin
      item  = wb_items.pop_front();
      item.end_wb(vif, log_commands);
    end
  endtask

  protected function tb_rice_core_env_pipeline_monitor_item create_monotor_item();
    tb_rice_core_env_pipeline_monitor_item  item;
    item    = new();
    item.id = instruction_id++;
    return item;
  endfunction

  protected function void output_log_commands(string log_commands[$]);
    longint unsigned  cycle_count;
    cycle_count = cycles - cycles_latest;
    $fdisplay(fd, "C\t%0d", cycle_count);
    foreach (log_commands[i]) begin
      $fdisplay(fd, log_commands[i]);
    end
  endfunction

  `tue_component_default_constructor(tb_rice_core_env_pipeline_monitor)
  `uvm_component_utils(tb_rice_core_env_pipeline_monitor)
endclass
