# $Id$

DESTDIR = /

OCAMLC = ocamlc -g
OCAMLMLI = ocamlc
OCAMLOPT = ocamlopt -unsafe
OCAMLDEP=ocamldep
OCAMLFLAGS=
OCAMLOPTFLAGS=
CFLAGS=-Wall
GLIBINC=`pkg-config --cflags glib-2.0`

IVY = ivy.ml ivyLoop.ml

IVYCMO= $(IVY:.ml=.cmo)
IVYCMI= $(IVY:.ml=.cmi)
IVYMLI= $(IVY:.ml=.mli)
IVYCMX= $(IVY:.ml=.cmx)

GLIBIVY = ivy.ml glibIvy.ml

GLIBIVYCMO= $(GLIBIVY:.ml=.cmo)
GLIBIVYCMI= $(GLIBIVY:.ml=.cmi)
GLIBIVYCMX= $(GLIBIVY:.ml=.cmx)

TKIVY = ivy.ml tkIvy.ml

TKIVYCMO= $(TKIVY:.ml=.cmo)
TKIVYCMI= $(TKIVY:.ml=.cmi)
TKIVYCMX= $(TKIVY:.ml=.cmx)

LIBS = ivy-ocaml.cma ivy-ocaml.cmxa glibivy-ocaml.cma glibivy-ocaml.cmxa
# tkivy-ocaml.cma tkivy-ocaml.cmxa

all : $(LIBS)

deb :
	dpkg-buildpackage -rfakeroot

ivy : ivy-ocaml.cma ivy-ocaml.cmxa
glibivy : glibivy-ocaml.cma glibivy-ocaml.cmxa
tkivy : tkivy-ocaml.cma tkivy-ocaml.cmxa

INST_FILES = $(IVYCMI) $(IVYMLI) glibIvy.cmi $(LIBS) libivy-ocaml.a libglibivy-ocaml.a dllivy-ocaml.so dllglibivy-ocaml.so ivy-ocaml.a glibivy-ocaml.a
# tkIvy.cmi  libtkivy-ocaml.a  dlltkivy-ocaml.so tkivy-ocaml.a

install : $(LIBS)
	mkdir -p $(DESTDIR)/`ocamlc -where`
	cp $(INST_FILES) $(DESTDIR)/`ocamlc -where`

desinstall :
	cd `ocamlc -where`; rm -f $(INST_FILES)

ivy-ocaml.cma : $(IVYCMO) civy.o civyloop.o
	ocamlmklib -o ivy-ocaml $^ -livy

ivy-ocaml.cmxa : $(IVYCMX) civy.o civyloop.o
	ocamlmklib -o ivy-ocaml $^ -livy

glibivy-ocaml.cma : $(GLIBIVYCMO) civy.o cglibivy.o
	ocamlmklib -o glibivy-ocaml $^ -lglibivy `pkg-config --libs glib-2.0` -lpcre

glibivy-ocaml.cmxa : $(GLIBIVYCMX) civy.o cglibivy.o
	ocamlmklib -o glibivy-ocaml $^ -lglibivy `pkg-config --libs glib-2.0` -lpcre

tkivy-ocaml.cma : $(TKIVYCMO) civy.o ctkivy.o
	ocamlmklib -o tkivy-ocaml $^ -livy -ltclivy

tkivy-ocaml.cmxa : $(TKIVYCMX) civy.o ctkivy.o
	ocamlmklib -o tkivy-ocaml $^ -livy -ltclivy

.SUFFIXES:
.SUFFIXES: .ml .mli .mly .mll .cmi .cmo .cmx .c .o .out .opt

.ml.cmo :
	$(OCAMLC) $(OCAMLFLAGS) $(INCLUDES) -c $<
.c.o :
	$(CC) -Wall -c $(GLIBINC) $<
.mli.cmi :
	$(OCAMLMLI) $(OCAMLFLAGS) -c $<
.ml.cmx :
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<
.mly.ml :
	ocamlyacc $<
.mll.ml :
	ocamllex $<
.cmo.out :
	$(OCAMLC) -custom -o $@ unix.cma -I . ivy-ocaml.cma $< -cclib -livy
.cmx.opt :
	$(OCAMLOPT) -o $@ unix.cmxa -I . ivy-ocaml.cmxa $< -cclib -livy

clean:
	\rm -f *.cm* *.o *.a .depend *~ *.out *.opt .depend *.so *_stamp

.depend:
	$(OCAMLDEP) $(INCLUDES) *.mli *.ml > .depend

include .depend
