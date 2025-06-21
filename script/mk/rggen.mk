PATH_CSR          := $(RICE_ROOT)/csr
CSR_CONFIGURATION := $(wildcard $(PATH_CSR)/*.yaml)
CSR_DEFINITION   	:= $(wildcard $(PATH_CSR)/*.rb)
CSR_RTL           := $(addsuffix .veryl, $(basename $(notdir $(CSR_DEFINITION))))

PATH_PLUGIN := rggen-veryl:$(PATH_SCRIPT)/rb/rggen-rice/lib/rggen/rice.rb
RGGEN       := RGGEN_PLUGINS=$(PATH_PLUGIN) rggen --print-backtrace

.PHONY: generate_rtl

generate_rtl: $(CSR_RTL)

%.veryl: $(PATH_CSR)/%.rb $(CSR_CONFIGURATION)
	$(RGGEN) --enable veryl -c $(PATH_CSR)/rice_csr_xlen32.yaml $<
