;
;
;
Not: MACRO ?value
	value:
		db 0
	Update:
		ld a,(?value)
		bit 6,a
		jr nz,False
		ld a,7FH
		ld (value),a
		ret
	False:
		xor a
		ld (value),a
		ret
	ENDM
