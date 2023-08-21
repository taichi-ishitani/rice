CLEAN += *.elf
CLEAN += *.bin
CLEAN += *.dump

PATH_RISCV_TESTS := $(PATH_TEST)/riscv/riscv-tests

RISCV_TEST_NAME     := $(shell basename $$(pwd) | cut -d '_' -f 3-)
RISCV_TEST_GROUP    := $(shell basename $$(pwd) | cut -d '_' -f 2)
RISCV_TEST_DIR      := $(PATH_RISCV_TESTS)/$(RISCV_TEST_GROUP)
RISCV_TEST_XLEN     ?= 32
RISCV_TEST_GCC_OPTS ?=

ifeq ($(RISCV_TEST_GROUP), isa)
  RISCV_TEST_ELF_FILE  = $(RISCV_TEST_NAME)
  RISCV_TEST_DUMP_FILE = $(RISCV_TEST_NAME).dump
endif
ifeq ($(RISCV_TEST_GROUP), benchmarks)
  RISCV_TEST_ELF_FILE  = $(RISCV_TEST_NAME).riscv
  RISCV_TEST_DUMP_FILE = $(RISCV_TEST_NAME).riscv.dump

  RISCV_TEST_GCC_OPTS += \
    $(filter-out RISCV_GCC_OPTS ?=,\
    $(filter-out -march=%,\
    $(filter-out -mabi=%,\
    $(shell grep RISCV_GCC_OPTS $(RISCV_TEST_DIR)/Makefile | grep ?=))))
  RISCV_TEST_GCC_OPTS += -march=rv$(RISCV_TEST_XLEN)im
endif

$(RISCV_TEST_NAME).bin: $(RISCV_TEST_NAME).elf
	riscv$(RISCV_TEST_XLEN)-unknown-elf-objcopy -O binary $(RISCV_TEST_ELF_FILE).elf $(RISCV_TEST_NAME).bin

$(RISCV_TEST_NAME).elf:
ifneq ($(strip $(RISCV_TEST_GCC_OPTS)),)
	$(MAKE) -C $(RISCV_TEST_DIR) $(RISCV_TEST_DUMP_FILE) XLEN=$(RISCV_TEST_XLEN) RISCV_GCC_OPTS="$(strip $(RISCV_TEST_GCC_OPTS))"
else
	$(MAKE) -C $(RISCV_TEST_DIR) $(RISCV_TEST_DUMP_FILE) XLEN=$(RISCV_TEST_XLEN)
endif
	mv $(RISCV_TEST_DIR)/$(RISCV_TEST_ELF_FILE) $(RISCV_TEST_ELF_FILE).elf
	mv $(RISCV_TEST_DIR)/$(RISCV_TEST_DUMP_FILE) $(RISCV_TEST_DUMP_FILE)

pre_sim_vcs: $(RISCV_TEST_NAME).bin
