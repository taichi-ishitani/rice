class tb_rice_core_env_pipeline_tracer extends tb_rice_core_env_pipeline_sub_monitor_base;
  protected int     fd;
  protected string  log_commands[$];
  longint           cycles_latest;

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    fd            = open_trace_file();
    cycles_latest = 0;
  endfunction

  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    close_trace_file();
  endfunction

  function void start_if(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
    log_commands.push_back($sformatf("I\t%0d\t%0d\t%0d", item.id, item.id, 0));
    log_commands.push_back($sformatf("S\t%0d\t%0d\t%s", item.id, 0, "if"));
  endfunction

  function void flush_if(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
    add_inst_label(item);
    log_commands.push_back($sformatf("R\t%0d\t%0d\t%0d", item.id, 0, 1));
  endfunction

  function void start_id(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
    log_commands.push_back($sformatf("S\t%0d\t%0d\t%s", item.id, 0, "id"));
  endfunction

  function void flush_id(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
    add_inst_label(item);
    log_commands.push_back($sformatf("R\t%0d\t%0d\t%0d", item.id, 0, 1));
  endfunction

  function void start_ex(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
    log_commands.push_back($sformatf("S\t%0d\t%0d\t%s", item.id, 0, "ex"));
  endfunction

  function void start_wb(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
    log_commands.push_back($sformatf("S\t%0d\t%0d\t%s", item.id, 0, "wb"));
  endfunction

  function void end_wb(longint cycles, tb_rice_core_env_pipeline_monitor_item item);
    add_inst_label(item);
    log_commands.push_back($sformatf("R\t%0d\t%0d\t%0d", item.id, 0, 0));
  endfunction

  function void end_monitor_cycle(longint cycles);
    if (log_commands.size() > 0) begin
      output_log_commands(cycles);
      cycles_latest = cycles;
    end
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
    $fdisplay(fd, "C=\t%0d", 0);

    return fd;
  endfunction

  protected function void close_trace_file();
    $fclose(fd);
  endfunction

  protected function void add_inst_label(tb_rice_core_env_pipeline_monitor_item item);
    log_commands.push_back($sformatf("L\t%0d\t%0d\t%s", item.id, 0, item.print_inst()));
  endfunction

  protected function void output_log_commands(longint cycles);
    longint unsigned  cycle_count;
    cycle_count = cycles - cycles_latest;
    $fdisplay(fd, "C\t%0d", cycle_count);
    foreach (log_commands[i]) begin
      $fdisplay(fd, log_commands[i]);
    end
    log_commands.delete();
  endfunction

  `tue_component_default_constructor(tb_rice_core_env_pipeline_tracer)
  `uvm_component_utils(tb_rice_core_env_pipeline_tracer)
endclass
