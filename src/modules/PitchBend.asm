;
;
;
PitchBend: MACRO ?bend, ?bendFraction, ?key, ?keyFraction, ?range, ?rangeFraction
	noteFraction:
		db 0
	note:
		db 0
	Update:
		ld a,(?rangeFraction)
		add a,a
		ld c,a
		ld a,(?range)
		ld b,a       ; bc = range as 8.8
		ld a,(?bendFraction)
		add a,a
		ld l,a
		ld a,(?bend)
		ld h,a
		add hl,hl
		add hl,hl    ; hl = bend as 0.16
		jr nc,Negative
	Positive:
		muluw hl,bc  ; dehl = offset as 16.16
		ld a,(?keyFraction)
		add a,a
		ld l,a
		ld a,(?key)
		rl h         ; round
		ld h,a
		adc hl,de
		jp p,PositiveNoClamp
		ld hl,7FFEH
	PositiveNoClamp:
		srl l
		ld (noteFraction),hl
		ret
	Negative:
		ex de,hl
		ld hl,0FFF8H
		sbc hl,de
		muluw hl,bc  ; dehl = offset as 16.16
		ld a,(?keyFraction)
		add a,a
		ld l,a
		ld a,(?key)
		rl h         ; round
		ld h,a
		sbc hl,de
		jp p,NegativeNoClamp
		ld hl,0000H
	NegativeNoClamp:
		srl l
		ld (noteFraction),hl
		ret
	ENDM
