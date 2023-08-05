BASIC_TEST_DIRS := $(sort $(wildcard basic_*))
SIM_BASIC_TESTS := $(addprefix sim_, $(BASIC_TEST_DIRS))

.PHONY: all run_all_basic_tests $(SIM_BASIC_TESTS)

run_all_tests: run_all_basic_tests run_all_riscv_tests

run_all_basic_tests: $(SIM_BASIC_TESTS)

$(SIM_BASIC_TESTS):
	$(MAKE) -C $(subst sim_,,$@)

include ../common.mk
include ../riscv_test_common.mk
