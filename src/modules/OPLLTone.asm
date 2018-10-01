;
;
;
OPLLTone: MACRO ?msxMusic, ?channel, ?instrument, ?volume, ?gate, ?trigger, ?key, ?keyFraction, ?sustain
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
		ld b,a
		ld a,(?keyFraction)
		add a,a
		ld c,a
		call OPLLTone_GetFNumBlock
		ld d,l
		ld a,10H + ?channel
		call WriteRegister
		ld a,(?gate)
		rrca
		rrca
		and 00010000B
		or h
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

; b = note number
; c = fraction
; hl <- fnum + block
OPLLTone_GetFNumBlock: PROC
	ld hl,0AAABH  ; de = hl * (1 / 1.5)
	muluw hl,bc
	ld hl,-5263  ; (-69 / 12 + log2(440) + 18 + log2(72) - log2(3579545) - 8) * 2048
	add hl,de
	ld a,h
	and ~07H
	ld c,0
	jp m,Continue
	cp 8 << 3
	jr nc,Clamp
	ld c,a
	ld a,h
	sub c
	ld h,a
Continue:
	call Math_Pow2
	ld l,h
	ld a,c
	rrca
	rrca
	or e
	ld h,a
	ret
Clamp:
	ld hl,0FFFH
	ret
	ENDP
