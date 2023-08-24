CLEAN += cosim
CLEAN += whisper_connect

PATH_COSIM              := $(PATH_TB)/cosim
PATH_COSIM_ARCH_CHECKER := $(PATH_COSIM)/cosim-arch-checker
PATH_WHISPER            ?= whisper

COSIM_XLEN     ?= 32
COSIM_ELF_FILE ?= $(wildcard *.elf)

.PHONY: create_cosim_build_dir compile_cosim_lib

create_cosim_build_dir:
	mkdir -p cosim/build
	mkdir -p cosim/lib
	for dir in bootrom bridge cac env mon; do \
		ln -fs ${PATH_COSIM_ARCH_CHECKER}/$${dir} cosim/$${dir}; \
	done
	ln -s ${PATH_COSIM}/params_xlen${COSIM_XLEN}.h cosim/params.h
	ln -s ${PATH_COSIM}/whisper_config_xlen${COSIM_XLEN}.json cosim/whisper_config.json
	cp ${PATH_COSIM_ARCH_CHECKER}/Makefile cosim/Makefile
	sed -i -e 's|CFLAGS =|CFLAGS = -I. |' -e 's|find .|find . -follow|' cosim/Makefile

compile_cosim_lib:
	[ -d cosim ] || $(MAKE) create_cosim_build_dir
	$(MAKE) -C cosim

ifeq ($(strip $(COSIM)), on)
  VCS_ARGS += +define+TB_RICE_ENABLE_COSIM

  SIMV_ARGS += -sv_lib $(PATH_SIM_BINARY)/cosim/lib/libcosim
  SIMV_ARGS += +testfile=$(COSIM_ELF_FILE)
  SIMV_ARGS += +whisper_json_path=$(PATH_SIM_BINARY)/cosim/whisper_config.json
  SIMV_ARGS += +whisper_path=$(PATH_WHISPER)
  SIMV_ARGS += +dutmon_tracer
  SIMV_ARGS += +bridge_tracer
  SIMV_ARGS += +enable_cosim

  pre_compile_vcs: compile_cosim_lib
endif
