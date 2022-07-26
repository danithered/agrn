PROGNAME=simulation

IDIR =./src/include
ODIR=./src/obj
SRCDIR=./src

CC=g++
C=gcc

#CFLAGS=-I$(IDIR) `pkg-config --cflags gsl` -ggdb -fexceptions -Wall -pg -no-pie # for testing
CFLAGS=-I$(IDIR) `pkg-config --cflags gsl` -Ofast # for stuff

LIBS=-lm `pkg-config --libs gsl` -fopenmp -lboost_system

_DEPS = randomgen.h expr_mod.h dv_tools.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ = randomgen.o main.o expr_mod.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

_OBJ_test = test.o 
OBJ_test = $(patsubst %,$(ODIR)/%,$(_OBJ_test))

$(ODIR)/%.o: $(SRCDIR)/%.cpp $(DEPS)
	@mkdir -p ${ODIR}
	$(CC) -c -o $@ $< $(CFLAGS)

$(ODIR)/%.o: $(SRCDIR)/%.c $(DEPS)
	$(C) -c -o $@ $< $(CFLAGS)

$(PROGNAME): $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)

.PHONY: clean

clean:
	rm -f $(ODIR)/*.o *~ core $(INCDIR)/*~  

.PHONY: run

run:
	./$(PROGNAME)  

test: $(OBJ_test)
	$(CC) -o $@ $^ $(CFLAGS) $(LIBS)
	./test

