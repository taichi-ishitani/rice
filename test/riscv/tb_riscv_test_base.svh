class tb_riscv_test_base #(
  type  BASE  = uvm_test
) extends BASE;
  const tb_rice_bus_address START_ADDRESS     = 'h8000_0000;
  const tb_rice_bus_address TOHOST_ADDRESS    = START_ADDRESS + 'h1000;
  const tb_rice_bus_address FROMHOST_ADDRESS  = START_ADDRESS + 'h1040;
  const longint             SYS_WRITE         = 64;

  task pre_reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    load_inst_data();
    phase.drop_objection(this);
  endtask

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    monitor_memory_access();
    phase.drop_objection(this);
  endtask

  protected virtual task load_inst_data();
    string              riscv_test_file;
    int                 fp;
    tb_rice_bus_address address;
    int                 byte_data;
    bit [31:0]          word_data;
    int                 byte_index;

    `tue_define_plusarg_string(+RISCV_TEST_FILE, riscv_test_file);
    `uvm_info(
      "LOAD_INST_DATA",
      $sformatf("load inst data from %s", riscv_test_file),
      UVM_NONE
    )

    fp  = $fopen(riscv_test_file, "r");
    if (fp == 0) begin
      `uvm_fatal(
        "LOAD_INST_DATA",
        $sformatf("cannot open such file: %s", riscv_test_file)
      )
    end

    address     = START_ADDRESS;
    byte_index  = 0;
    while (1) begin
      byte_data = $fgetc(fp);
      if (byte_data == -1) begin
        break;
      end

      word_data[8*byte_index+:8]  = byte_data;
      if (byte_index == 3) begin
        put_word_data(address, word_data);
        address     = address + 4;
        byte_index  = 0;
      end
      else begin
        byte_index  = byte_index + 1;
      end
    end

    $fclose(fp);
  endtask

  protected virtual function void put_word_data(
    tb_rice_bus_address address,
    bit [31:0]          word_data
  );
  endfunction

  protected virtual task monitor_memory_access();
    tb_rice_bus_item  bus_item;

    while (1) begin
      get_data_bus_item(bus_item);
      if (!access_to_tohost(bus_item)) begin
        continue;
      end

      if (bus_item.data[0]) begin
        if (bus_item.data == 1) begin
          `uvm_info(
            "CHECK_RESULT",
            "all tests are passed", UVM_NONE
          )
        end
        else if (bus_item.data[0]) begin
          int test_no = bus_item.data >> 1;
          `uvm_error(
            "CHECK_RESULT",
            $sformatf("test no %0d is faield", test_no)
          )
        end

        break;
      end
      else begin
        process_syscall(bus_item.data);
      end
    end

    configuration.tb_context.clock_vif.wait_cycles(10);
  endtask

  protected virtual task get_data_bus_item(ref tb_rice_bus_item item);
  endtask

  protected virtual function bit access_to_tohost(
    tb_rice_bus_item  bus_item
  );
    return bus_item.is_write() && (bus_item.address == TOHOST_ADDRESS);
  endfunction

  protected virtual function void process_syscall(tb_rice_bus_data data);
    bit [63:0]  magic_mem[4];
    bit [63:0]  which;

    foreach (magic_mem[i]) begin
      magic_mem[i][32*0+:32]  = get_word_data(data + 8 * i + 0);
      magic_mem[i][32*0+:32]  = get_word_data(data + 8 * i + 0);
    end

    which = magic_mem[0];
    case (which)
      SYS_WRITE:  process_sys_write(magic_mem[2], magic_mem[3]);
      default:    `uvm_fatal("SYSCALL", $sformatf("unknown syscall: %0d", which))
    endcase

    put_word_data(FROMHOST_ADDRESS, 1);
  endfunction

  protected virtual function void process_sys_write(
    tb_rice_bus_address buffer_address,
    longint             buffer_size
  );
    bit [31:0]  data;
    string      buffer_string;

    for (int i = 0;i < buffer_size;i += 4) begin
      data          = get_word_data(buffer_address + i);
      buffer_string = {buffer_string, string'(data[8*0+:8])};
      buffer_string = {buffer_string, string'(data[8*1+:8])};
      buffer_string = {buffer_string, string'(data[8*2+:8])};
      buffer_string = {buffer_string, string'(data[8*3+:8])};
    end

    `uvm_info(
      "SYSCALL", $sformatf("syswrite: %s", buffer_string), UVM_NONE
    )
  endfunction

  protected virtual function bit [31:0] get_word_data(tb_rice_bus_address address);
    return 0;
  endfunction

  `tue_component_default_constructor(tb_riscv_test_base)
endclass
