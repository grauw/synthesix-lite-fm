Synthesix Lite FM
=================

Copyright 2018 Laurens Holst

Project information
-------------------

Simple MIDI synthesizer for OPLL and PSG.

Author: Laurens Holst <laurens.nospam@grauw.nl>  
Site: <https://bitbucket.org/grauw/synthesix-lite-fm>  
License: Simplified BSD License


System Requirements
-------------------

* MSX turbo R
* 128K main RAM
* 16K video RAM
* MSX-DOS 2


Usage instructions
------------------

Run SyntheFM from MSX-DOS 2, optionally specifying a MIDI file to play on the
command line.

Usage:

    synthefm [options] <file.mid>

Options:

* `/b` Enter blackout mode during playback.
  
  This setting makes the screen go black during playback. For machines with a
  lot of VDP interference on the audio output, this may reduce the amount of
  interference.


Development information
-----------------------

Synthesix Lite FM is free and open source software. If you want to contribute
to the project you are very welcome to. Please contact me at any one of the
places mentioned in the project information section.

You are also free to re-use code for your own projects, provided you abide by
the license terms.

Synthesix Lite FM depends on the library project Neonlib; it is recommended
to clone the project with Mercurial so they will automatically be pulled in
at the correct version, otherwise you have to download them manually:

    hg clone https://bitbucket.org/grauw/synthesix-lite-fm

Building the project is really easy on all modern desktop platforms. On MacOS
and Linux, simply invoke `make` to build the binary and symbol files into the
`bin` directory:

    make

Windows users can open the `Makefile` and build by pasting the line in the `all`
target into the Windows command prompt.

To launch the build in openMSX after building, put a copy of `MSXDOS2.SYS` and
`COMMAND2.COM` and in the `bin` directory, and invoke the `make run` command.

Note that the [glass](https://bitbucket.org/grauw/glass) assembler which is
embedded in the project requires [Java 8](http://java.com/getjava). To check
your Java version, invoke the `java -version` command.
