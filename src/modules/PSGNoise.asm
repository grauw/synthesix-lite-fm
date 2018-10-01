;
;
;
PSGNoise: MACRO ?psg, ?channel, ?key, ?keyFraction, ?gate
	WriteRegister: equ ?psg + PSG.WriteRegister
	ReadRegister: equ ?psg + PSG.ReadRegister
	Update:
		ld a,(?key)
		ld b,a
		ld a,(?keyFraction)
		add a,a
		ld c,a
		call PSGNoise_GetPeriod
		ld d,l
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

; b = note number
; c = fraction
; hl <- period
PSGNoise_GetPeriod:
	ld hl,0AAABH  ; de = hl * (1 / 1.5)
	muluw hl,bc
	ld hl,-14869  ; (69 / 12 - 6 - log2(440) - log2(16) + log2(3579545) - 16) * 2048
	and a
	sbc hl,de
	call Math_Pow2
	ld a,l
	and ~1FH
	or h
	ret z
	ld hl,1FH  ; clamp
	ret
