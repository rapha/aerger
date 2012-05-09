run_test: test
	./test

test: aerger.cmo test.cmo
	ocamlc aerger.cmo test.cmo -o test

clean:
	rm -f .depend *.cm? test

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
