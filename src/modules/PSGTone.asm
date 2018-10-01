;
;
;
PSGTone: MACRO ?psg, ?channel, ?key, ?keyFraction, ?gate, ?volume
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
		ld b,a
		ld a,(?keyFraction)
		add a,a
		ld c,a
		call PSGTone_GetPeriod
		ld d,l
		ld a,00H + ?channel * 2
		call WriteRegister
		ld d,h
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

; b = note number
; c = fraction
; hl <- period
PSGTone_GetPeriod:
	ld hl,0AAABH  ; de = hl * (1 / 1.5)
	muluw hl,bc
	ld hl,13803  ; (69 / 12 - log2(440) - log2(16) + log2(3579545) - 8) * 2048
	and a
	sbc hl,de
	call Math_Pow2
	ld l,h
	ld h,e
	ld a,h
	and ~0FH
	ret z
	ld hl,0FFFH  ; clamp
	ret
