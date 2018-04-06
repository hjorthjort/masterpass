default: compile dictionaries

compile:
	ghc --make -O -odir out/ -hidir out/ -o out/masterpass flags.hs masterpass.hs

dictionaries:
	python getdicts.py
