LASTRELEASE:=$(shell ../svntools/lastrelease -n)
RSCARDUINO = Capacity FreqCounter huehner OneWire onewireclock \
    OW_Devices temperature time timer water
SRC=Makefile $(RSCARDUINO) README README.html

USERNAME=schlatterbeck
PROJECT=rsc-arduino
PACKAGE=rsc-arduino
CHANGES=changes
NOTES=notes

LICENSE=GNU General Public License (GPL)
URL=http://$(PROJECT).sourceforge.net/

all: $(SRC)

dist: all
	tar cvf rsc-arduino-$(LASTRELEASE) $(SRC)

clean:
	rm -f notes changes default.css \
	      README.html README.aux README.dvi README.log README.out \
	      README.tex
	rm -rf dist build upload upload_homepage ReleaseNotes.txt

include ../make/Makefile-sf
