PATH_COSIM              := $(PATH_TB)/cosim
PATH_COSIM_ARCH_CHECKER := $(PATH_COSIM)/cosim-arch-checker
PATH_WHISPER            ?= whisper

COSIM_XLEN     ?= 32
COSIM_FILELIST := cosim_runtime.f

CLEAN += cosim
CLEAN += whisper_connect
CLEAN += $(COSIM_FILELIST)

.PHONY: create_cosim_build_dir compile_cosim_lib flgen_cosim

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

flgen_cosim:
	flgen --runtime --output $(COSIM_FILELIST) $(PATH_COSIM)/cosim_runtime.rb

export $(PATH_WHISPER)

ifeq ($(strip $(COSIM)), on)
  VCS_ARGS  += +define+TB_RICE_ENABLE_COSIM
  SIMV_ARGS += -f $(COSIM_FILELIST)

  pre_compile_vcs: compile_cosim_lib
  sim_vcs: flgen_cosim
endif
