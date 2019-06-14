GCC ?= gcc
INCLUDEPATH ?= /usr/local/include
LIBPATH ?= /usr/local/lib/
CFLAGS ?= -O2 -fPIC -shared -std=c11 -I$(INCLUDEPATH) -Wall
LINKFLAGS ?= -ldl -lffi -L$(LIBPATH)

all: hdll

.PHONY: hdll

hdll:
	mkdir -p ../../out/hl/
	$(GCC) $(CFLAGS) -D LIBHL_EXPORTS -o ../../out/hl/callfunc.hdll callfunc.c $(LINKFLAGS)
