
cpu	:= $(shell uname -m)
os	:= $(shell uname -s)
ver	:= 0.1
dst := _build/geohash-$(os)-$(cpu)-$(ver).cgi

final: build $(dst)

lib/res.ml:	res res/doap.rdf res/doap2html.xslt
	find res -name .DS_Store -delete
	# opam install ocp-ocamlres
	ocp-ocamlres -format ocaml $< -o $@

$(dst): _build/default/bin/geohash.exe
	cp $< $@
	chmod u+w $@
	strip $@
	ls -l $@

test/assert.ml:
	curl --location --output $@ https://raw.githubusercontent.com/benjenkinsv95/ocaml-unit-testing-helpers/master/assert.ml

#
# https://github.com/ocaml/dune/tree/master/example/sample-projects/hello_world
# via https://stackoverflow.com/a/54712669
#
.PHONY: all build clean test install uninstall doc examples

build: lib/res.ml
	@echo "let git_sha = \""`git rev-parse --short HEAD`"\"" > bin/version.ml
	@echo "let date = \""`date +'%FT%T%z'`"\""              >> bin/version.ml
	dune build bin/geohash.exe

all: build

test: test/assert.ml
	dune runtest

examples:
	dune build @examples

install:
	dune install

uninstall:
	dune uninstall

doc:
	dune build @doc

clean:
	rm -rf lib/res.ml _build *.install
