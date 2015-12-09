# Makefile for llcheck
TESTS = tests/test tests/test-operators tests/test-types tests/test-utils tests/test-most tests/test-derive
OBJS = $(shell find Test -name \*.hs | sed -e 's/.hs$$/.o/')
GHCIMPORTDIRS = .

%.o: %.hs
	ghc $<

%: %.hs
	ghc $<

all: $(OBJS)

test: all $(TESTS)
	./tests/test
	./tests/test-operators
	./tests/test-types
	./tests/test-utils
	./tests/test-most
	./tests/test-derive

clean: clean-hi-o
	rm -f $(TESTS)

include mk/haskell.mk