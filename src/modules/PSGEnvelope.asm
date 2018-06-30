;
;
;
PSGEnvelope: MACRO ?psg, ?channel, ?shape, ?key, ?gate
	WriteRegister: equ ?psg + PSG.WriteRegister
	ReadRegister: equ ?psg + PSG.ReadRegister
	Update:
		ld a,0DH
		call ReadRegister
		ld e,a
		ld a,(?shape)
		and 07H
		or 08H
		ld d,a
		cp e
		ld a,0DH
		call nz,WriteRegister
		ld a,(?key)
		add a,a
		ld e,a
		ld d,0
		ld hl,PSGEnvelope_frequencyTable
		add hl,de
		ld d,(hl)
		ld a,0BH
		call WriteRegister
		inc hl
		ld d,(hl)
		ld a,0CH
		call WriteRegister
		ld a,08H + ?channel
		call ReadRegister
		and 11101111B
		ld d,a
		ld a,(?gate)
		rrca
		rrca
		and 00010000B
		or d
		ld d,a
		ld a,08H + ?channel
		jp WriteRegister
	ENDM

; ix = this
PSGEnvelope_Construct:
	ret
