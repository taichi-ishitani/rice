RICE_ROOT   := $(shell git rev-parse --show-toplevel)
PATH_SCRIPT := $(RICE_ROOT)/script
PATH_RTL    := $(RICE_ROOT)/rtl

SOURCE := $(RICE_ROOT)/inst/riscv_inst.yaml
RESULT := $(PATH_RTL)/common/rice_riscv_inst_matcher_pkg.sv

$(RESULT): $(SOURCE)
	ruby $(PATH_SCRIPT)/rb/create_inst_matcher.rb $< $@
