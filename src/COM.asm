;
; Synthesix Lite FM
;

	INCLUDE "Macros.asm"

DEBUG: equ 0

HEAP: equ 0C000H
HEAP_SIZE: equ 1180H
STACK_SIZE: equ 100H

	org 100H

RAM_PAGE0: ds 3F00H
RAM_PAGE1: ds 4000H

TPA: equ RAM_PAGE0
TPA_PAGE0: equ RAM_PAGE0
RAM_RESIDENT: equ RAM_PAGE0
TPA_PAGE1: equ RAM_PAGE1
RAM: equ RAM_PAGE1

	SECTION TPA

;
; Program entry point
;
COM_Main:
	jp Application_Main

	INCLUDE "DOS.asm"
	INCLUDE "BIOS.asm"
	INCLUDE "Class.asm"
	INCLUDE "System.asm"
	INCLUDE "Memory.asm"
	INCLUDE "MemoryTest.asm"
	INCLUDE "Mapper.asm"
	INCLUDE "Heap.asm"
	INCLUDE "HeapTest.asm"
	INCLUDE "VDP.asm"
	INCLUDE "Application.asm"
	INCLUDE "CLI.asm"
	INCLUDE "Hook.asm"
	INCLUDE "MidiIn.asm"
	INCLUDE "MSXMidi.asm"
	INCLUDE "MSXMusic.asm"
	INCLUDE "PSG.asm"
	INCLUDE "Synthesizer.asm"
	INCLUDE "Resources.asm"
	INCLUDE "modules/Channel.asm"
	INCLUDE "modules/Note.asm"
	INCLUDE "modules/Constants.asm"
	INCLUDE "modules/OPLLChannel.asm"
	INCLUDE "modules/OPLLBasicChannel.asm"
	INCLUDE "modules/OPLLTone.asm"
	INCLUDE "modules/OPLLVoice.asm"
	INCLUDE "modules/PSGToneChannel.asm"
	INCLUDE "modules/PSGNoiseChannel.asm"
	INCLUDE "modules/PSGEnvelopeChannel.asm"
	INCLUDE "modules/PSGTone.asm"
	INCLUDE "modules/PSGNoise.asm"
	INCLUDE "modules/PSGEnvelope.asm"
	INCLUDE "modules/Clamp.asm"
	INCLUDE "modules/Not.asm"
	INCLUDE "modules/Or.asm"
	INCLUDE "modules/Attenuate.asm"

	ENDS

	SECTION RAM_PAGE0

Heap_main:
	Heap HEAP, HEAP_SIZE

	ENDS
