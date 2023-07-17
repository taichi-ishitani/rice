CLEAN += csrc
CLEAN += simv*
CLEAN += *.fsdb
CLEAN += *.vpd
CLEAN += ucli.key
CLEAN += vc_hdrs.h
CLEAN += DVEfiles
CLEAN += .inter.vpd.uvm
CLEAN += .restartSimSession.tcl.old

VCS_ARGS += -full64
VCS_ARGS += -sverilog
VCS_ARGS += -timescale=1ns/1ps
VCS_ARGS += -l vcs.log
VCS_ARGS += -ntb_opts uvm-$(UVM_VERSION)
VCS_ARGS += +define+UVM_NO_DEPRECATED
VCS_ARGS += +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTO

SIMV_ARGS += -l simv.log
SIMV_ARGS += +UVM_VERBOSITY=$(VERBOSITY)
SIMV_ARGS += +UVM_TIMEOUT=$(TIMEOUT)
SIMV_ARGS += +UVM_MAX_QUIT_COUNT=$(ERROR_COUNT),no

ifeq ($(strip $(GUI)), verdi)
  VCS_ARGS += -debug_access+all
	VCS_ARGS += -kdb
	VCS_ARGS += +vcs+fsdbon

	SIMV_ARGS += -gui=verdi
	SIMV_ARGS += +fsdb+struct=on
	SIMV_ARGS += +fsdb+packedmda=on
endif
ifeq ($(strip $(GUI)), dve)
  VCS_ARGS += -debug_access+all
	VCS_ARGS += +vcs+vcdpluson

	SIMV_ARGS += -gui=dve
endif

ifeq ($(strip $(DUMP)), fsdb)
  VCS_ARGS += -debug_access
	VCS_ARGS += -kdb
	VCS_ARGS += +vcs+fsdbon

	SIMV_ARGS += +fsdb+struct=on
	SIMV_ARGS += +fsdb+packedmda=on
	SIMV_ARGS += +fsdbfile+dump.fsdb
endif
ifeq ($(strip $(DUMP)), vpd)
  VCS_ARGS += -debug_access
	VCS_ARGS += +vcs+vcdpluson

	SIMV_ARGS += -vpd_file=dump.vpd
endif

ifeq ($(strip $(RANDOM_SEED)), auto)
  SIMV_ARGS += +ntb_random_seed_automatic
else
  SIMV_ARGS += +ntb_random_seed=$(RANDOM_SEED)
endif

VCS_ARGS += -f $(FILELIST_COMPILE)
VCS_ARGS += -top tb

PATH_SIM_BINARY := ../sim_binary
PATH_SIMV       := $(PATH_SIM_BINARY)/simv

.PHONY: compile_vcs __compile_vcs pre_sim_vcs sim_vcs

compile_vcs:
	$(MAKE) -C $(PATH_SIM_BINARY) __compile_vcs

__compile_vcs: flgen_vcs
	[ -f $(PATH_SIMV) ] || vcs $(VCS_ARGS)

pre_sim_vcs:

sim_vcs: compile_vcs pre_sim_vcs
	$(PATH_SIMV) $(SIMV_ARGS)
