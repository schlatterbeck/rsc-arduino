LASTRELEASE:=$(shell ../svntools/lastrelease -n)
RSCARDUINO=Capacity FreqCounter huehner OneWire onewireclock \
    OW_Devices temperature time timer water
SUBDIRS=FreqCounter/Examples FreqCounter/Examples/FreqCounterLib_example \
    OneWire/examples
EXCLUDE=$(RSCARDUINO:%=--exclude rsc-arduino-$(RELEASE)/%/.svn) \
    $(SUBDIRS:%=--exclude rsc-arduino-$(RELEASE)/%/.svn)
SRC=$(RSCARDUINO) README README.html

USERNAME=schlatterbeck
PROJECT=rsc-arduino
PACKAGE=rsc-arduino
CHANGES=changes
NOTES=notes

LICENSE=GNU General Public License version 3.0 (GPLv3)
URL=http://$(PROJECT).sourceforge.net/

all: $(SRC) Makefile

dist: all
	mkdir rsc-arduino-$(RELEASE)
	cp -a $(SRC) rsc-arduino-$(RELEASE)
	tar cvzf rsc-arduino-$(RELEASE).tar.gz $(EXCLUDE) rsc-arduino-$(RELEASE)

clean:
	rm -f notes changes default.css \
	      README.html README.aux README.dvi README.log README.out \
	      README.tex
	rm -rf dist build upload upload_homepage ReleaseNotes.txt

include ../make/Makefile-sf
