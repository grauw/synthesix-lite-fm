;
;
;
Or: MACRO ?a, ?b
	value:
		db 0
	Update:
		ld a,(?b)
		ld b,a
		ld a,(?a)
		or b
		bit 6,a
		jr z,False
		ld a,7FH
		ld (value),a
		ret
	False:
		xor a
		ld (value),a
		ret
	ENDM
