;
;
;
PSGNoise: MACRO ?psg, ?channel, ?key, ?gate
	WriteRegister: equ ?psg + PSG.WriteRegister
	ReadRegister: equ ?psg + PSG.ReadRegister
	Update:
		ld a,(?key)
		ld e,a
		ld d,0
		ld hl,PSGNoise_frequencyTable
		add hl,de
		ld d,(hl)
		ld a,06H
		call WriteRegister
		ld a,07H
		call ReadRegister
		and ~(1 << (?channel + 3))
		ld d,a
		ld a,(?gate)
		bit 6,a
		jr nz,Gate
		set ?channel + 3,d
	Gate:
		ld a,07H
		jp WriteRegister
	ENDM

; ix = this
PSGNoise_Construct:
	ret
