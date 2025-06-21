VERYL ?= veryl

.PHONY: veryl_build veryl_clean

veryl_build:
	$(VERYL) build

veryl_clean:
	$(VERYL) clean
