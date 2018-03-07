
CXX=g++
CFLAGS=-g -O2 -fPIC

HL_SRC=../../src/

PYTHON_INC=/usr/include/python2.5/

PERL_INC=`perl -MExtUtils::Embed -eperl_inc`

lib-stamp: 
	make -C ${HL_SRC} -f ./makefile clean
	make -C ${HL_SRC} -f ./makefile CFLAGS="${CFLAGS}" libhighlight.a
	touch $@

python: lib-stamp
	swig -c++ -python -o highlight_wrap.cpp  highlight.i
	${CXX} ${CFLAGS} -c highlight_wrap.cpp  -I${PYTHON_INC} -I${HL_SRC}
	${CXX} -shared -s highlight_wrap.o  -L${HL_SRC} -lhighlight -o _highlight.so

perl: lib-stamp
	swig -c++ -perl -o highlight_wrap.cpp  highlight.i
	${CXX} ${CFLAGS} -c highlight_wrap.cpp ${PERL_INC} -I${HL_SRC}
	${CXX} -shared -s highlight_wrap.o  -L${HL_SRC} -lhighlight -o highlight.so


clean: python-clean perl-clean
	rm *-stamp

perl-clean:
	rm -f highlight.so highlight_wrap.cpp highlight.pm *.o


.PHONY: python python-clean perl perl-clean clean
