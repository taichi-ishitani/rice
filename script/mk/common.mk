RICE_ROOT := $(shell git rev-parse --show-toplevel)

PATH_SCRIPT := $(RICE_ROOT)/script
PATH_RTL    := $(RICE_ROOT)/rtl
PATH_TB     := $(RICE_ROOT)/tb
PATH_TEST   := $(RICE_ROOT)/test

FILELIST         ?= $(wildcard *.rb)
FILELIST_COMPILE ?= compile.f
FILELIST_RUNTIME ?= runtime.f
DUMP             ?= off
GUI              ?= off
UVM_VERSION      ?= 1.2
RANDOM_SEED      ?= auto
VERBOSITY        ?= UVM_LOW
TIMEOUT          ?= 1_000_000
ERROR_COUNT      ?= 1

RISCV_TESTS ?= off

-include $(PATH_SCRIPT)/mk/flgen.mk
-include $(PATH_SCRIPT)/mk/vcs.mk
ifeq ($(strip $(RISCV_TESTS)), on)
  -include $(PATH_SCRIPT)/mk/riscv-tests.mk
endif

CLEAN += *.log

.PHONY:	clean

clean:
	rm -rf $(CLEAN)
