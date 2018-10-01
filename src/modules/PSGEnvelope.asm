;
;
;
PSGEnvelope: MACRO ?psg, ?channel, ?shape, ?key, ?keyFraction, ?gate
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
		ld b,a
		ld a,(?keyFraction)
		add a,a
		ld c,a
		call PSGEnvelope_GetPeriod
		ld d,l
		ld a,0BH
		call WriteRegister
		ld d,h
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

; b = note number
; c = fraction
; hl <- period
PSGEnvelope_GetPeriod:
	ld hl,0AAABH  ; de = hl * (1 / 1.5)
	muluw hl,bc
	ld hl,5611  ; (69 / 12 - log2(440) - log2(256) + log2(3579545) - 8) * 2048
	and a
	sbc hl,de
	call Math_Pow2
	ld l,h
	ld h,e
	ret
