run_test: test
	./test

test: args.cmi args.cmo test.cmo
	ocamlc args.cmo test.cmo -o test

demo: args.cmi args.cmo demo.cmo
	ocamlc args.cmo demo.cmo -o demo

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
