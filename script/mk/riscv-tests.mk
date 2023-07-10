CLEAN += *.bin

PATH_RISCV_TESTS := $(PATH_TEST)/riscv/riscv-tests

RISCV_TEST_NAME  := $(word 3,$(shell basename $$(pwd) | tr '_' ' '))
RISCV_TEST_GROUP := $(word 2,$(shell basename $$(pwd) | tr '_' ' '))
RISCV_TEST_DIR   := $(PATH_RISCV_TESTS)/$(RISCV_TEST_GROUP)
RISCV_TEST_XLEN  ?= 32

$(RISCV_TEST_NAME).bin: $(RISCV_TEST_DIR)/$(RISCV_TEST_NAME)
	riscv$(RISCV_TEST_XLEN)-unknown-elf-objcopy -O binary \
		$(RISCV_TEST_DIR)/$(RISCV_TEST_NAME) $(RISCV_TEST_NAME).bin

$(RISCV_TEST_DIR)/$(RISCV_TEST_NAME):
	$(MAKE) -C $(RISCV_TEST_DIR) $(RISCV_TEST_NAME) XLEN=$(RISCV_TEST_XLEN)

pre_sim_vcs: $(RISCV_TEST_NAME).bin
