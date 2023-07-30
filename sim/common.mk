SIM_DIRS       := $(sort $(subst /makefile,,$(wildcard */makefile)))
SIM_DIRS_CLEAN := $(addprefix clean_, $(SIM_DIRS))

clean: $(SIM_DIRS_CLEAN)

$(SIM_DIRS_CLEAN):
	$(MAKE) -C $(subst clean_,,$@) clean
