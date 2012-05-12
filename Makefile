run_test: test
	./test

test: aerger.cmo test.cmo
	ocamlc aerger.cmo test.cmo -o test

aerger.cma: aerger.cmi aerger.cmo
	ocamlc -a -o aerger.cma aerger.cmo

clean:
	rm -f .depend *.cm? test

install: aerger.cmi aerger.cma META
	ocamlfind install aerger aerger.cmi aerger.cma META

uninstall:
	ocamlfind remove aerger

# simple file transforms
.SUFFIXES: .mli .ml .cmi .cmo
.mli.cmi:
	ocamlc -c $<
.ml.cmo:
	ocamlc -c $<

# autogenerate source dependencies
.depend: *.mli *.ml
	ocamldep *.mli *.ml >.depend
include .depend

.PHONY: clean run_test
