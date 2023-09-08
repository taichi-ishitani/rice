module tb_rice_core_env_inst_checker
  import  rice_core_pkg::*;
(
  input var                     i_clk,
  input var                     i_rst_n,
  rice_core_pipeline_if.monitor pipeline_if
);
  import  uvm_pkg::*;
  `include  "uvm_macros.svh"

  ast_valid_instruction:
  assert
    property (
      @(posedge i_clk) disable iff (!i_rst_n)
      pipeline_if.id_result.valid |->
        (pipeline_if.id_result.alu_operation.command     != RICE_CORE_ALU_NONE          ) ||
        (pipeline_if.id_result.mul_operation             != '0                          ) ||
        (pipeline_if.id_result.div_operation             != '0                          ) ||
        (pipeline_if.id_result.branch_operation          != '0                          ) ||
        (pipeline_if.id_result.memory_access.access_type != RICE_CORE_MEMORY_ACCESS_NONE) ||
        (pipeline_if.id_result.csr_access                != RICE_CORE_CSR_ACCESS_NONE   ) ||
        (pipeline_if.id_result.trap_control              != '0                          ) ||
        (pipeline_if.id_result.ordering_control[1:0]     != '0                          )
    )
  else
    `uvm_fatal(
      "INVALID_INST",
      $sformatf(
        "invalid instruction is given: pc %h inst %h",
        $past(pipeline_if.if_result.pc), $past(pipeline_if.if_result.inst)
      )
    )

  function automatic bit is_check_disabled();
    uvm_cmdline_processor clp;
    string                args[$];

    clp = uvm_cmdline_processor::get_inst();
    if (clp.get_arg_matches("+disable_inst_check", args)) begin
      return 1;
    end
    else begin
      return 0;
    end
  endfunction

  initial begin
    if (is_check_disabled()) begin
      $assertoff(0, ast_valid_instruction);
    end
  end
endmodule
