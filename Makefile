default: compile dictionaries run

COMPILE_FLAGS = --make -O -odir out/ -hidir out/ -o out/masterpass
FILES = flags.hs masterpass.hs

deps:
	stack install random split

compile: deps
	@mkdir -p out
	ghc $(COMPILE_FLAGS) $(FILES) \
		|| stack ghc -- $(COMPILE_FLAGS) $(FILES)

dictionaries:
	python3 getdicts.py

run:
	./out/masterpass -u -n -use-specials -w=4
