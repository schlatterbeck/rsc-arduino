LASTRELEASE:=$(shell ../svntools/lastrelease -n)
RSCARDUINO=Capacity FreqCounter huehner OneWire onewireclock \
    OW_Devices temperature time timer water
SUBDIRS=FreqCounter/Examples FreqCounter/Examples/FreqCounterLib_example \
    OneWire/examples
EXCLUDE=$(RSCARDUINO:%=--exclude %/.svn) $(SUBDIRS:%=--exclude %/.svn)
SRC=$(RSCARDUINO) README README.html

USERNAME=schlatterbeck
PROJECT=rsc-arduino
PACKAGE=rsc-arduino
CHANGES=changes
NOTES=notes

LICENSE=GNU General Public License (GPL)
URL=http://$(PROJECT).sourceforge.net/

all: $(SRC) Makefile

dist: all
	tar cvzf rsc-arduino-$(LASTRELEASE).tar.gz $(EXCLUDE) $(SRC)

clean:
	rm -f notes changes default.css \
	      README.html README.aux README.dvi README.log README.out \
	      README.tex
	rm -rf dist build upload upload_homepage ReleaseNotes.txt

include ../make/Makefile-sf
