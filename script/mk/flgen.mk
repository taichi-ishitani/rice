CLEAN += $(FILELIST_COMPILE)
CLEAN += $(FILELIST_RUNTIME)

.PHONY:	flgen flgen_vcs

flgen:
	flgen --compile --output $(FILELIST_COMPILE) $(FILELIST)

flgen_vcs:
	flgen	--tool=vcs --compile --output $(FILELIST_COMPILE) $(FILELIST)
