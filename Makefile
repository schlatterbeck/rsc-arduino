# To use this Makefile, get a copy of my SF Release Tools
# git clone git://git.code.sf.net/p/sfreleasetools/code sfreleasetools
# And point the environment variable RELEASETOOLS to the checkout

ifeq (,${RELEASETOOLS})
    RELEASETOOLS=../releasetools
endif
LASTRELEASE:=$(shell $(RELEASETOOLS)/lastrelease -n)
RSCARDUINO=Capacity FreqCounter huehner OneWire onewireclock \
    OW_Devices temperature time timer water
SUBDIRS=FreqCounter/Examples FreqCounter/Examples/FreqCounterLib_example \
    OneWire/examples
EXCLUDE=$(RSCARDUINO:%=--exclude rsc-arduino-$(RELEASE)/%/.svn) \
    $(SUBDIRS:%=--exclude rsc-arduino-$(RELEASE)/%/.svn)
README=README.rst
SRC=$(RSCARDUINO) $(README) README.html

USERNAME=schlatterbeck
PROJECT=rsc-arduino
PACKAGE=rsc-arduino
CHANGES=changes
NOTES=notes

LICENSE=GNU General Public License version 3.0 (GPLv3)
URL=http://$(PROJECT).sourceforge.net/

all: $(SRC) Makefile

dist: all
	rm -rf build
	mkdir -p build/rsc-arduino-$(RELEASE) dist
	cp -a $(SRC) build/rsc-arduino-$(RELEASE)
	cd build && \
	tar cvzf rsc-arduino-$(RELEASE).tar.gz $(EXCLUDE) rsc-arduino-$(RELEASE)
	mv build/rsc-arduino-$(RELEASE).tar.gz dist

clean:
	rm -f notes changes default.css \
	      README.html README.aux README.dvi README.log README.out \
	      README.tex
	rm -rf dist build upload upload_homepage ReleaseNotes.txt

include $(RELEASETOOLS)/Makefile-sf
