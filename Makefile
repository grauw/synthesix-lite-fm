COPY_TARGET = /Volumes/MSXDOS2

all:
	mkdir -p bin
	java -jar tools/glass.jar -I gen -I lib/neonlib/src src/COM.asm bin/synthefm.com bin/synthefm.sym

dist: all
	cp README.md CHANGES.md LICENSE bin/
	rm -f bin/synthefm.zip
	cd bin && zip synthefm.zip synthefm.com README.md CHANGES.md LICENSE

copy: all
	cp bin/synthefm.com $(COPY_TARGET)/
	diskutil umount $(COPY_TARGET)

run: all
	openmsx -machine Panasonic_FS-A1GT -ext ide openmsx.tcl

run2: all
	openmsx -machine Philips_NMS_8245 -ext ide openmsx.tcl

run3: all
	openmsx -machine Yamaha_CX5M -ext MegaFlashROM_SCC\+_SD openmsx.tcl
