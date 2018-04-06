default: compile dictionaries run

compile:
	ghc --make -O -odir out/ -hidir out/ -o out/masterpass flags.hs masterpass.hs

dictionaries:
	python getdicts.py

run:
	./out/masterpass -u -n -use-specials
