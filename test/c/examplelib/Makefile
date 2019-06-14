GCC ?= gcc
CFLAGS ?= -g -fPIC -shared -std=c11 -Wall

all: lib

.PHONY: lib

lib:
	mkdir -p ../../../out/lib/
	$(GCC) $(CFLAGS) -o ../../../out/lib/examplelib.so examplelib.c
