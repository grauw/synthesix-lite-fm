;
;
;
OPLLNote: MACRO ?channel, ?instrument, ?volume, ?channelVolume, ?gate, ?legato, ?key, ?offVelocity, ?sustain
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
		call WriteRegister
		ld a,(?key)
		add a,a
		ld e,a
		ld d,0
		ld hl,OPLLNote_frequencyTable
		add hl,de
		ld d,(hl)
		ld a,10H
		call WriteRegister
		inc hl
		ld a,(?gate)
		ld b,a
		ld a,(?legato)
		or b
		rrca
		rrca
		and 00010000B
		or (hl)
		ld d,a
		ld a,(?offVelocity)
		cpl
		ld b,a
		ld a,(?sustain)
		or b
		bit 6,a
		jr z,NoSustain
		set 5,d
	NoSustain:
		ld a,20H
	; a = register base
	; d = value
	WriteRegister:
		add a,?channel
		jp System_ThrowException
	writeRegister: equ $ - 2
	ENDM

; de = MSX Music
; ix = this
OPLLNote_Construct:
	ld hl,MSXMusic.WriteRegister
	add hl,de
	ld (ix + OPLLNote.writeRegister),l
	ld (ix + OPLLNote.writeRegister + 1),h
	ret

;
OPLLNote_frequencyTable:
	INCLUDE "FNumTable.asm"
