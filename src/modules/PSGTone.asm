;
;
;
PSGTone: MACRO ?psg, ?channel, ?key, ?gate, ?volume
	WriteRegister: equ ?psg + PSG.WriteRegister
	ReadRegister: equ ?psg + PSG.ReadRegister
	Update:
		ld a,08H + ?channel
		call ReadRegister
		and 0F0H
		ld d,a
		ld a,(?volume)
		rrca
		rrca
		rrca
		and 0FH
		or d
		ld d,a
		ld a,08H + ?channel
		call WriteRegister
		ld a,(?key)
		add a,a
		ld e,a
		ld d,0
		ld hl,PSGTone_frequencyTable
		add hl,de
		ld d,(hl)
		ld a,00H + ?channel * 2
		call WriteRegister
		inc hl
		ld d,(hl)
		ld a,01H + ?channel * 2
		call WriteRegister
		ld a,07H
		call ReadRegister
		and ~(1 << ?channel)
		ld d,a
		ld a,(?gate)
		bit 6,a
		jr nz,Gate
		set ?channel,d
	Gate:
		ld a,07H
		jp WriteRegister
	ENDM
