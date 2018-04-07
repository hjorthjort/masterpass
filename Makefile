default: compile dictionaries run

compile:
	@mkdir -p out
	ghc --make -O -odir out/ -hidir out/ -o out/masterpass flags.hs masterpass.hs

dictionaries:
	python getdicts.py

run:
	./out/masterpass -u -n -use-specials -w=4
