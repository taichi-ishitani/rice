include riscv_tests.mk

DIR_RISCV_TESTS = $(addprefix dir_, $(RISCV_TESTS))
SIM_RISCV_TESTS = $(addprefix sim_, $(RISCV_TESTS))

.PHONY: create_riscv_tests $(DIR_RISCV_TESTS) $(SIM_RISCV_TESTS)

create_riscv_tests: $(DIR_RISCV_TESTS)

$(DIR_RISCV_TESTS):
	[ -d $(subst dir_,,$@) ] || mkdir $(subst dir_,,$@)
	cd $(subst dir_,,$@); ln -f -s ../riscv_test_common.mk makefile

run_all_riscv_tests: $(SIM_RISCV_TESTS)

$(SIM_RISCV_TESTS):
	$(MAKE) -C $(subst sim_,,$@)
