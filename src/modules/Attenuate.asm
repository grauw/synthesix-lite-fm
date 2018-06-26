;
;
;
Attenuate: MACRO ?augend, ?addend
	value:
		db 0
	Update:
		ld a,(?addend)
		ld b,a
		ld a,(?augend)
		add a,b
		sub 127
		jr nc,NoClamp
		xor a
	NoClamp:
		ld (value),a
		ret
	ENDM
