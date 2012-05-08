run_test: test
	./test

test: aerger.cmi aerger.cmo test.cmo
	ocamlc aerger.cmo test.cmo -o test

demo: aerger.cmi aerger.cmo demo.cmo
	ocamlc aerger.cmo demo.cmo -o demo

clean:
	rm -f .depend *.cm? demo test

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
