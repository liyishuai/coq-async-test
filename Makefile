COQMAKEFILE ?= Makefile.coq

all: $(COQMAKEFILE)
	@+$(MAKE) -f $^ all

clean: $(COQMAKEFILE)
	@+$(MAKE) -f $^ cleanall
	@rm -f `cat .gitignore`

$(COQMAKEFILE): _CoqProject
	$(COQBIN)coq_makefile -f _CoqProject -o $@

force _CoqProject Makefile: ;

%: $(COQMAKEFILE) force
	@+$(MAKE) -f $^ $@

.PHONY: all clean force
