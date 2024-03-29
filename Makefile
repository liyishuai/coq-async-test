COQMAKEFILE ?= Makefile.coq

all: $(COQMAKEFILE)
	@+$(MAKE) -f $^ all

clean: $(COQMAKEFILE)
	@+$(MAKE) -f $^ cleanall
	@rm -f `cat .gitignore` $(COQMAKEFILE) $(COQMAKEFILE).conf

$(COQMAKEFILE): _CoqProject
	$(COQBIN)coq_makefile -f _CoqProject -o $@

install: $(COQMAKEFILE)
	@+$(MAKE) -f $^ $@

test:
	$(MAKE) -C test

.PHONY: all clean install test

publish%:
	opam publish --packages-directory=released/packages \
		--repo=coq/opam-coq-archive --tag=v$* -v $* liyishuai/coq-async-test
