package tb_rice_cosim_pkg;
  import  uvm_pkg::*;

  localparam  int HARTS = `TB_RICE_COSIM_HARTS;
  localparam  int XLEN  = `TB_RICE_COSIM_XLEN;
  localparam  int VLEN  = `TB_RICE_COSIM_VLEN;

`ifdef TB_RICE_ENABLE_COSIM
  import "DPI-C" function env_init();
  import "DPI-C" function env_final();
  import "DPI-C" function monitor_instr(input string name, input int hartid, input longint cycle, input longint tag, input longint pc, input int opcode, input int trap);
  import "DPI-C" function monitor_gpr(input string name, input int hartid, input longint cycle, input int rd_addr, input longint rd_wdata);
  import "DPI-C" function monitor_fpr(input string name, input int hartid, input longint cycle, input int frd_addr, input longint frd_wdata);
  import "DPI-C" function monitor_vr(input string name, input int hartid, input longint cycle, input int vrd_addr, input longint vrd_wdata[VLEN/64]);
  import "DPI-C" function monitor_csr(input string name, input int hartid, input longint cycle, input int csr_addr, input longint csr_wdata);
`else
  function automatic void env_init();
  endfunction
  function automatic void env_final();
  endfunction
  function automatic void monitor_instr(input string name, input int hartid, input longint cycle, input longint tag, input longint pc, input int opcode, input int trap);
  endfunction
  function automatic void monitor_gpr(input string name, input int hartid, input longint cycle, input int rd_addr, input longint rd_wdata);
  endfunction
  function automatic void monitor_fpr(input string name, input int hartid, input longint cycle, input int frd_addr, input longint frd_wdata);
  endfunction
  function automatic void monitor_vr(input string name, input int hartid, input longint cycle, input int vrd_addr, input longint vrd_wdata[VLEN/64]);
  endfunction
  function automatic void monitor_csr(input string name, input int hartid, input longint cycle, input int csr_addr, input longint csr_wdata);
  endfunction
`endif

  class tb_rice_cosim_proxy extends uvm_object;
    protected int hartid;

    function new(string name, int hartid);
      super.new(name);
      this.hartid = hartid;
    endfunction

    function void init();
      env_init();
    endfunction

    function void teardown();
      env_final();
    endfunction

    function void instr(longint cycle, longint tag, longint pc, int opcode, int trap);
      monitor_instr("mon_instr", hartid, cycle, tag, pc, opcode, trap);
    endfunction

    function void gpr(longint cycle, int rd_addr, longint rd_wdata);
      monitor_gpr("mon_instr", hartid, cycle, rd_addr, rd_wdata);
    endfunction

    function void csr(longint cycle, input int csr_addr, input longint csr_wdata);
      monitor_csr("mon_instr", hartid, cycle, csr_addr, csr_wdata);
    endfunction
  endclass
endpackage
