Synthesix Lite FM
=================

Copyright 2018 Laurens Holst

Project information
-------------------

Simple MIDI synthesizer for MSX-MUSIC (YM2413 OPLL) and PSG.

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


MIDI channel assignment
-----------------------

* Channel 1: FM basic channel
* Channels 1-9: FM voices
* Channels 7-11: FM rhythm voices (if enabled)
* Channel 12: PSG basic channel
* Channels 12-14: PSG tones
* Channel 15: PSG noise
* Channel 16: PSG envelope

All channels are monophonic.


MIDI controller assignment
--------------------------

All channels respond to:

* Velocity, CC 7, CC 11: Level
* CC 64: Key hold (sustain)

Overlap the notes to play legato.

* FM Voice channels 1-9
  * Program change:
    1. Original
    2. Violin
    3. Guitar
    4. Piano
    5. Flute
    6. Clarinet
    7. Oboe
    8. Trumpet
    9. Organ
    10. Horn
    11. Synthesizer
    12. Harpsicord
    13. Vibraphone
    14. Synthesizer Bass
    15. Acoustic Bass
    16. Electric Guitar
  * Key-off velocity (< 63: FM sustain, ≥ 64: no FM sustain)

* FM Basic channel 1
  * CC 16: Carrier Multiplier
  * CC 19: Carrier Level Key Scale
  * CC 20: Carrier EG Attack
  * CC 21: Carrier EG Decay
  * CC 22: Carrier EG Sustain
  * CC 23: Carrier EG Release
  * CC 24: Modulator Multiplier
  * CC 25: Modulator Level
  * CC 26: Modulator Feedback
  * CC 27: Modulator Level Key Scale
  * CC 28: Modulator EG Attack
  * CC 29: Modulator EG Decay
  * CC 30: Modulator EG Sustain
  * CC 31: Modulator EG Release
  * CC 80: Carrier LFO Amplitude (≥ 64: on)
  * CC 81: Carrier LFO Pitch (≥ 64: on)
  * CC 82: Carrier EG Mode (< 64: percussive, ≥ 64: sustained (default))
  * CC 83: Carrier EG Rate Key Scale (≥ 64: on)
  * CC 84: Carrier PG Waveform (< 64: sine, ≥ 64: rectified half sine)
  * CC 88: Modulator LFO Amplitude (≥ 64: on)
  * CC 89: Modulator LFO Pitch (≥ 64: on)
  * CC 90: Modulator EG Mode (< 64: percussive, ≥ 64: sustained (default))
  * CC 91: Modulator EG Rate Key Scale (≥ 64: on)
  * CC 92: Modulator PG Waveform (< 64: sine, ≥ 64: rectified half sine)


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
