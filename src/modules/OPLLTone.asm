;
;
;
OPLLTone: MACRO ?msxMusic, ?channel, ?instrument, ?volume, ?gate, ?trigger, ?key, ?sustain
	WriteRegister: equ ?msxMusic + MSXMusic.WriteRegister
	Update:
		ld a,(?trigger)
		bit 6,a
		jr z,NoTrigger
		ld a,0
	last20H: equ $ - 1
		bit 4,a
		jr z,NoTrigger
		and 11101111B
		ld d,a
		ld a,20H + ?channel
		jp WriteRegister
	NoTrigger:
		ld a,(?instrument)
		add a,a
		add a,a
		add a,a
		add a,a
		ld d,a
		ld a,(?volume)
		cpl
		rrca
		rrca
		rrca
		and 0FH
		or d
		ld d,a
		ld a,30H + ?channel
		call WriteRegister
		ld a,(?key)
		add a,a
		ld e,a
		ld d,0
		ld hl,OPLLTone_frequencyTable
		add hl,de
		ld d,(hl)
		ld a,10H + ?channel
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
		ld a,d
		ld (last20H),a
		ld a,20H + ?channel
		jp WriteRegister
	ENDM

; ix = this
OPLLTone_Construct:
	ret
