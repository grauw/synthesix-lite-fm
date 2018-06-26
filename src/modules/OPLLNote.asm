;
;
;
OPLLNote: MACRO ?msxMusic, ?channel, ?instrument, ?volume, ?channelVolume, ?gate, ?key, ?sustain
	WriteRegister: equ ?msxMusic + MSXMusic.WriteRegister
	Update:
		ld a,(?instrument)
		add a,a
		add a,a
		add a,a
		add a,a
		ld d,a
		ld a,(?volume)
		ld b,a
		ld a,(?channelVolume)
		add a,b
		sub 127
		jr nc,NoClip
		xor a
	NoClip:
		cpl
		rrca
		rrca
		rrca
		and 0FH
		or d
		ld d,a
		ld a,30H
		add a,?channel
		call WriteRegister
		ld a,(?key)
		add a,a
		ld e,a
		ld d,0
		ld hl,OPLLNote_frequencyTable
		add hl,de
		ld d,(hl)
		ld a,10H
		add a,?channel
		call WriteRegister
		inc hl
		ld a,(?gate)
		rrca
		rrca
		and 00010000B
		or (hl)
		ld d,a
		ld a,(?sustain)
		bit 6,a
		jr z,NoSustain
		set 5,d
	NoSustain:
		ld a,20H
		add a,?channel
		jp WriteRegister
	ENDM

; ix = this
OPLLNote_Construct:
	ret

;
OPLLNote_frequencyTable:
	INCLUDE "FNumTable.asm"
