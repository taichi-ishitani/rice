include ../common.mk
include $(PATH_SCRIPT)/mk/riscv-tests.mk

SIMV_ARGS += +RISCV_TEST_FILE=$(RISCV_TEST_NAME).bin
SIMV_ARGS += +UVM_TESTNAME=tb_rice_core_riscv_test
