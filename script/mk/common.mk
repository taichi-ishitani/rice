RICE_ROOT := $(shell git rev-parse --show-toplevel)

PATH_SCRIPT := $(RICE_ROOT)/script
PATH_RTL    := $(RICE_ROOT)/rtl
PATH_TB     := $(RICE_ROOT)/tb

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

-include $(PATH_SCRIPT)/mk/flgen.mk
-include $(PATH_SCRIPT)/mk/vcs.mk
-include local.mk

CLEAN += *.log

.PHONY:	clean

clean:
	rm -rf $(CLEAN)
