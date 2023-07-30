BASIC_TEST_DIRS := $(sort $(wildcard basic_*))
SIM_BASIC_TESTS := $(addprefix sim_, $(BASIC_TEST_DIRS))

run_all_basic_tests: $(SIM_BASIC_TESTS)

$(SIM_BASIC_TESTS):
	$(MAKE) -C $(subst sim_,,$@)

include ../common.mk
