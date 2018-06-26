;
;
;
Clamp: MACRO ?value, ?min, ?max
	value:
		db 0
	Update:
		ld a,(?min)
		ld b,a
		ld a,(?max)
		ld c,a
		ld a,(?value)
		cp b
		jr nc,NoMin
		ld a,b
		jr Set
	NoMin:
		cp c
		jr c,Set
		ld a,c
	Set:
		ld (value),a
		ret
	ENDM
