PATH_CSR          := $(RICE_ROOT)/csr
CSR_CONFIGURATION := $(wildcard $(PATH_CSR)/*.yaml)
CSR_DEFINITIONS   := $(wildcard $(PATH_CSR)/rice_csr_*_level.rb)
CSR_RTL           := $(addsuffix .sv, $(basename $(notdir $(CSR_DEFINITIONS))))

PATH_PLUGIN := $(PATH_SCRIPT)/rb/rggen-rice/lib/rggen/rice.rb
RGGEN       := RGGEN_PLUGINS=$(PATH_PLUGIN) rggen --print-backtrace

.PHONY: generate_rtl

generate_rtl: $(CSR_RTL)

%.sv: $(PATH_CSR)/%.rb $(CSR_CONFIGURATION)
	XLEN=32 $(RGGEN) --enable sv_rtl -c $(PATH_CSR)/rice_csr_xlen32.yaml $<
